import { DocumentSnapshot, FieldValue } from "firebase-admin/firestore";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db, region } from "./firebase";

export interface StockLine {
  productId: string;
  quantity: number;
}

interface ShortageLine extends StockLine {
  lineId?: string;
}

type Shortages = Record<string, { status?: string; replacement?: StockLine }>;

/**
 * The stock this order is holding right now. Checkout reserves every ordered
 * item. Once packing finishes `reconcileOrderStock` swaps that for what the
 * customer really gets and saves it as `reservedItems`; until then (and for
 * orders from before this existed) the reservation is simply the items.
 */
export function reservedLines(order: DocumentSnapshot): StockLine[] {
  const reserved = order.get("reservedItems");
  return (Array.isArray(reserved) ? reserved : order.get("items") ?? []) as StockLine[];
}

/**
 * What the customer gets after shortages: removed lines are gone and an
 * accepted replacement stands in for the line it replaces. Mirrors
 * `Order.effectiveItems` in the app.
 */
export function effectiveStockLines(order: DocumentSnapshot): StockLine[] {
  const items = (order.get("items") ?? []) as ShortageLine[];
  const shortages = (order.get("shortages") ?? {}) as Shortages;
  const lines: StockLine[] = [];
  for (const item of items) {
    const shortage = item.lineId ? shortages[item.lineId] : undefined;
    if (shortage?.status === "removed") continue;
    if (shortage?.status === "accepted" && shortage.replacement) {
      lines.push({ productId: shortage.replacement.productId, quantity: shortage.replacement.quantity });
    } else {
      lines.push({ productId: item.productId, quantity: item.quantity });
    }
  }
  return lines;
}

function totals(lines: StockLine[]): Map<string, number> {
  const byProduct = new Map<string, number>();
  for (const line of lines) {
    byProduct.set(line.productId, (byProduct.get(line.productId) ?? 0) + line.quantity);
  }
  return byProduct;
}

/**
 * When packing finishes, makes the stock match what the customer gets.
 * Checkout reserved the *ordered* items, so after a shortage:
 * - an item that was removed, or replaced, has its reservation put back;
 * - an accepted replacement has its own stock taken.
 * The packer found the original unavailable, so the count that comes back may
 * be wrong on the shelf; Store Admin corrects it in Inventory. A replacement
 * with less stock than needed (someone else bought it meanwhile) takes the
 * count to zero and is listed in `stockShort` instead of going negative.
 *
 * Idempotent (`stockSettled`), and stored as `reservedItems` so a later cancel
 * puts back exactly what is held.
 */
export const reconcileOrderStock = onDocumentUpdated(
  { document: "orders/{orderId}", region },
  async (event) => {
    const before = event.data?.before;
    const after = event.data?.after;
    if (!before || !after) return;
    if (before.get("status") === "ready" || after.get("status") !== "ready") return;

    const ref = after.ref;
    await db.runTransaction(async (tx) => {
      const order = await tx.get(ref);
      if (order.get("status") !== "ready" || order.get("stockReserved") !== true ||
          order.get("stockReleased") === true || order.get("stockSettled") === true) {
        return;
      }
      const held = totals(reservedLines(order));
      const effective = effectiveStockLines(order);
      const wanted = totals(effective);

      // Positive: put back. Negative: take.
      const change = new Map<string, number>();
      for (const productId of new Set([...held.keys(), ...wanted.keys()])) {
        const delta = (held.get(productId) ?? 0) - (wanted.get(productId) ?? 0);
        if (delta !== 0) change.set(productId, delta);
      }

      const branchId = order.get("branchId");
      const refs = [...change.keys()].map((id) => db.doc(`branches/${branchId}/inventory/${id}`));
      const inventories = await Promise.all(refs.map((item) => tx.get(item)));
      const short: string[] = [];
      [...change.entries()].forEach(([productId, delta], index) => {
        const inventory = inventories[index];
        if (!inventory.exists) return;
        const stock = Number(inventory.get("stock") ?? 0);
        const next = Math.max(0, stock + delta);
        if (stock + delta < 0) short.push(productId);
        tx.update(refs[index], { stock: next });
      });
      tx.update(order.ref, {
        stockSettled: true,
        ...(change.size > 0 ? { reservedItems: effective } : {}),
        ...(short.length > 0 ? { stockShort: short } : {}),
      });
    });
  },
);

/** Puts back whatever stock the order still holds, once. */
export async function releaseReservedStock(orderId: string): Promise<void> {
  const ref = db.doc(`orders/${orderId}`);
  await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (order.get("stockReserved") !== true || order.get("stockReleased") === true) return;
    const lines = reservedLines(order);
    const refs = lines.map((line) => db.doc(`branches/${order.get("branchId")}/inventory/${line.productId}`));
    const inventories = await Promise.all(refs.map((item) => tx.get(item)));
    inventories.forEach((inventory, index) => {
      if (inventory.exists) tx.update(refs[index], { stock: FieldValue.increment(lines[index].quantity) });
    });
    tx.update(ref, { stockReleased: true });
  });
}
