import { FieldValue, Transaction, DocumentSnapshot } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db, region } from "./firebase";

// The Grocerly Wallet is simulated: a balance and a list of entries in
// Firestore, changed only here with the Admin SDK. Clients can read their own
// wallet but never write it (see firestore.rules), so a modified app cannot
// give itself money. No real payment provider is involved.

export const maxTopUp = 500;
export const maxBalance = 2000;

export function money(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

export function walletRef(uid: string) {
  return db.doc(`users/${uid}/wallet/current`);
}

export type EntryType = "topUp" | "payment" | "refund" | "adjustment";

/**
 * Adds one entry to the wallet inside [tx]. [wallet] must have been read in
 * the same transaction before any write. [amount] is signed: positive adds
 * money, negative takes it. Returns the new balance.
 */
export function postEntry(
  tx: Transaction,
  uid: string,
  wallet: DocumentSnapshot,
  entry: { type: EntryType; amount: number; description: string; orderId?: string },
): number {
  const before = typeof wallet.get("balance") === "number" ? (wallet.get("balance") as number) : 0;
  const balanceAfter = money(before + entry.amount);
  tx.set(walletRef(uid), { balance: balanceAfter, updatedAt: FieldValue.serverTimestamp() });
  tx.create(db.collection(`users/${uid}/walletTransactions`).doc(), {
    type: entry.type,
    amount: money(entry.amount),
    balanceAfter,
    description: entry.description,
    ...(entry.orderId ? { orderId: entry.orderId } : {}),
    createdAt: FieldValue.serverTimestamp(),
  });
  return balanceAfter;
}

interface Line {
  lineId?: string;
  unitPrice: number;
  quantity: number;
}

/** What the customer owes after shortages: the same sum the apps show. */
export function adjustedTotal(order: DocumentSnapshot): number {
  const items = (order.get("items") ?? []) as Line[];
  const shortages = (order.get("shortages") ?? {}) as Record<
    string,
    { status?: string; replacement?: Line }
  >;
  let subtotal = 0;
  for (const item of items) {
    const shortage = item.lineId ? shortages[item.lineId] : undefined;
    let line: Line | null = item;
    if (shortage?.status === "removed") line = null;
    else if (shortage?.status === "accepted" && shortage.replacement) line = shortage.replacement;
    if (line) subtotal += line.unitPrice * line.quantity;
  }
  subtotal = money(subtotal);
  const discount = Number(order.get("discount") ?? 0);
  const fee = Number(order.get("deliveryFee") ?? 0);
  const reduction = Math.min(discount, subtotal);
  return Math.max(0, money(subtotal + fee - reduction));
}

export const topUpWallet = onCall({ region }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Please sign in.");
  const data = (request.data ?? {}) as Record<string, unknown>;
  const amount = data.amount;
  if (typeof amount !== "number" || !Number.isFinite(amount) || amount < 1 || amount > maxTopUp ||
      Math.round(amount * 100) !== amount * 100) {
    throw new HttpsError("invalid-argument", `Top up between RM 1 and RM ${maxTopUp}.`);
  }
  const method = typeof data.method === "string" && data.method.length <= 40
    ? data.method.trim() : "";
  return db.runTransaction(async (tx) => {
    const [user, wallet] = await Promise.all([tx.get(db.doc(`users/${uid}`)), tx.get(walletRef(uid))]);
    if (user.get("role") !== "customer" || user.get("isActive") === false) {
      throw new HttpsError("permission-denied", "Customer account required.");
    }
    const current = typeof wallet.get("balance") === "number" ? (wallet.get("balance") as number) : 0;
    if (current + amount > maxBalance) {
      throw new HttpsError("failed-precondition", `A wallet can hold at most RM ${maxBalance}.`);
    }
    const balance = postEntry(tx, uid, wallet, {
      type: "topUp", amount,
      description: method ? `Top up (${method})` : "Top up",
    });
    return { balance };
  });
});

/**
 * Keeps the wallet in step with an order:
 * - when packing finishes (status becomes ready) it settles the shortages: a
 *   refund for removed or cheaper items, or a charge for dearer replacements;
 * - when the order is cancelled it refunds what is still held, and puts
 *   reserved stock back if nothing else has.
 * Both steps are idempotent (flags on the order), so a retried trigger never
 * pays twice.
 */
export const settleOrderWallet = onDocumentUpdated(
  { document: "orders/{orderId}", region },
  async (event) => {
    const before = event.data?.before;
    const after = event.data?.after;
    if (!before || !after) return;
    const ref = after.ref;
    const becameReady = before.get("status") !== "ready" && after.get("status") === "ready";
    const becameCancelled = before.get("status") !== "cancelled" && after.get("status") === "cancelled";
    if (!becameReady && !becameCancelled) return;

    await db.runTransaction(async (tx) => {
      const order = await tx.get(ref);
      const uid = order.get("customerId") as string;
      const wallet = await tx.get(walletRef(uid));
      const held = order.get("walletPaid");
      const number = order.get("number");

      if (becameCancelled && order.get("status") === "cancelled") {
        if (typeof held === "number" && held > 0) {
          postEntry(tx, uid, wallet, {
            type: "refund", amount: held, orderId: ref.id,
            description: `Refund for cancelled order #${number}`,
          });
          tx.update(ref, { walletPaid: 0, walletRefundedAt: FieldValue.serverTimestamp() });
        }
        return;
      }

      if (becameReady && order.get("status") === "ready" && order.get("walletSettled") !== true &&
          typeof held === "number") {
        const owed = adjustedTotal(order);
        const difference = money(owed - held);
        if (difference !== 0) {
          postEntry(tx, uid, wallet, {
            type: difference < 0 ? "refund" : "adjustment",
            amount: -difference, orderId: ref.id,
            description: difference < 0
              ? `Refund for unavailable items on order #${number}`
              : `Replacement price difference on order #${number}`,
          });
        }
        tx.update(ref, { walletPaid: owed, walletSettled: true });
      }
    });

    if (becameCancelled) await releaseStockIfNeeded(ref.id);
  },
);

async function releaseStockIfNeeded(orderId: string): Promise<void> {
  const ref = db.doc(`orders/${orderId}`);
  await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (order.get("stockReserved") !== true || order.get("stockReleased") === true) return;
    const items = (order.get("items") ?? []) as Array<{ productId: string; quantity: number }>;
    const refs = items.map((item) => db.doc(`branches/${order.get("branchId")}/inventory/${item.productId}`));
    const inventories = await Promise.all(refs.map((item) => tx.get(item)));
    inventories.forEach((inventory, index) => {
      if (inventory.exists) tx.update(refs[index], { stock: FieldValue.increment(items[index].quantity) });
    });
    tx.update(ref, { stockReleased: true });
  });
}
