import { randomInt } from "node:crypto";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, GeoPoint } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "./firebase";
import { reservedLines } from "./stock";
import { money, postEntry, walletRef } from "./wallet";

export { notifyOrderChanges } from "./notifications";
export { reconcileOrderStock } from "./stock";
export { settleOrderWallet, topUpWallet } from "./wallet";

function object(value: unknown): Record<string, unknown> {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError("invalid-argument", "Invalid request.");
  }
  return value as Record<string, unknown>;
}

function string(value: unknown, field: string, max = 120): string {
  if (typeof value !== "string" || !value.trim() || value.length > max) {
    throw new HttpsError("invalid-argument", `Invalid ${field}.`);
  }
  return value.trim();
}

function optionalString(value: unknown, field: string, max = 500): string | null {
  if (value === undefined || value === null || value === "") return null;
  return string(value, field, max);
}

function customerUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Please sign in.");
  return uid;
}

async function requireAdmin(uid: string | undefined): Promise<void> {
  const id = customerUid(uid);
  const profile = await db.doc(`users/${id}`).get();
  if (profile.get("role") !== "storeAdmin" || profile.get("isActive") === false) {
    throw new HttpsError("permission-denied", "HQ admin access required.");
  }
}

function distanceKm(from: GeoPoint, to: GeoPoint): number {
  const radians = Math.PI / 180;
  const a = from.latitude * radians;
  const b = to.latitude * radians;
  const deltaLat = (to.latitude - from.latitude) * radians;
  const deltaLng = (to.longitude - from.longitude) * radians;
  const chord = Math.sin(deltaLat / 2) ** 2 +
    Math.cos(a) * Math.cos(b) * Math.sin(deltaLng / 2) ** 2;
  return 6371 * 2 * Math.asin(Math.sqrt(chord));
}

const alphabet = "ACDEFGHJKMNPQRTUVWXY3479";
function collectionCode(): string {
  return Array.from({ length: 8 }, () => alphabet[randomInt(alphabet.length)]).join("");
}

export const placeOrder = onCall({ region: "asia-southeast1" }, async (request) => {
  const uid = customerUid(request.auth?.uid);
  const input = object(request.data);
  const branchId = string(input.branchId, "branch", 100);
  const fulfilment = input.fulfilment;
  if (fulfilment !== "delivery" && fulfilment !== "pickup") {
    throw new HttpsError("invalid-argument", "Invalid fulfilment method.");
  }
  const rawLines = input.lines;
  if (!Array.isArray(rawLines) || rawLines.length < 1 || rawLines.length > 100) {
    throw new HttpsError("invalid-argument", "Your cart is empty or too large.");
  }
  const lines = rawLines.map((raw) => {
    const line = object(raw);
    const quantity = line.quantity;
    if (!Number.isInteger(quantity) || (quantity as number) < 1 || (quantity as number) > 99) {
      throw new HttpsError("invalid-argument", "Invalid quantity.");
    }
    return { productId: string(line.productId, "product", 100), quantity: quantity as number };
  });
  if (new Set(lines.map((line) => line.productId)).size !== lines.length) {
    throw new HttpsError("invalid-argument", "Duplicate products in cart.");
  }
  const addressId = fulfilment === "delivery" ? string(input.addressId, "address", 100) : null;
  const promoCode = optionalString(input.promoCode, "promo code", 30)?.toUpperCase();
  if (promoCode && promoCode !== "FRESH5") {
    throw new HttpsError("invalid-argument", "Invalid promo code.");
  }
  const customerNote = optionalString(input.customerNote, "order note");

  const userRef = db.doc(`users/${uid}`);
  const branchRef = db.doc(`branches/${branchId}`);
  const addressRef = addressId ? db.doc(`users/${uid}/addresses/${addressId}`) : null;
  const counterRef = db.doc("counters/orders");
  const customerWalletRef = walletRef(uid);
  const productRefs = lines.map((line) => db.doc(`products/${line.productId}`));
  const inventoryRefs = lines.map((line) => db.doc(`branches/${branchId}/inventory/${line.productId}`));
  const orderRef = db.collection("orders").doc();
  const code = collectionCode();

  return db.runTransaction(async (tx) => {
    // Firestore requires every read before the first write. Reading inventory
    // in this transaction also makes concurrent stock reservations conflict.
    const [user, branch, address, counter, wallet, ...catalogue] = await Promise.all([
      tx.get(userRef), tx.get(branchRef),
      addressRef ? tx.get(addressRef) : Promise.resolve(null),
      tx.get(counterRef), tx.get(customerWalletRef),
      ...productRefs.map((ref) => tx.get(ref)),
      ...inventoryRefs.map((ref) => tx.get(ref)),
    ]);
    if (user.get("role") !== "customer" || user.get("isActive") === false) {
      throw new HttpsError("permission-denied", "Customer account required.");
    }
    if (!branch.exists || branch.get("isTemporarilyClosed") === true) {
      throw new HttpsError("failed-precondition", "This store is closed.");
    }
    if (addressRef && (!address?.exists || !(address.get("location") instanceof GeoPoint))) {
      throw new HttpsError("failed-precondition", "Choose a saved delivery address.");
    }
    const count = lines.length;
    const products = catalogue.slice(0, count);
    const inventories = catalogue.slice(count);
    const items = lines.map((line, index) => {
      const product = products[index];
      const inventory = inventories[index];
      const price = inventory.get("price");
      const stock = inventory.get("stock");
      if (!product.exists || !inventory.exists || inventory.get("isHidden") === true ||
          typeof price !== "number" || !Number.isFinite(price) || price < 0 ||
          !Number.isInteger(stock) || stock < line.quantity) {
        throw new HttpsError("failed-precondition", "An item is unavailable. Refresh your cart.");
      }
      return {
        lineId: line.productId,
        productId: line.productId,
        name: product.get("name") ?? "",
        brand: product.get("brand") ?? "",
        packSize: product.get("packSize") ?? "",
        quantity: line.quantity,
        unitPrice: money(price),
        ...(product.get("categoryId") ? { categoryId: product.get("categoryId") } : {}),
        ...(product.get("description") ? { description: product.get("description") } : {}),
        ...(Array.isArray(product.get("imageUrls")) && product.get("imageUrls")[0]
          ? { imageUrl: product.get("imageUrls")[0] } : {}),
      };
    });
    const subtotal = money(items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0));
    let deliveryFee = 0;
    if (address && address.exists) {
      const origin = branch.get("location");
      const destination = address.get("location");
      const radius = branch.get("maxDeliveryKm");
      const base = branch.get("baseDeliveryFee");
      const perKm = branch.get("feePerKm");
      if (!(origin instanceof GeoPoint) || !(destination instanceof GeoPoint) ||
          typeof radius !== "number" || typeof base !== "number" || typeof perKm !== "number" ||
          radius < 0 || base < 0 || perKm < 0) {
        throw new HttpsError("failed-precondition", "Delivery is unavailable at this store.");
      }
      const km = distanceKm(origin, destination);
      if (km > radius) throw new HttpsError("failed-precondition", "Address is outside the delivery area.");
      deliveryFee = money(base + Math.ceil(km) * perKm);
    }
    const discount = promoCode === "FRESH5" ? Math.min(5, subtotal) : 0;
    const number = (counter.exists ? counter.get("value") : 1000) + 1;
    if (!Number.isSafeInteger(number)) throw new HttpsError("internal", "Order number unavailable.");
    const total = money(subtotal + deliveryFee - discount);
    const balance = typeof wallet.get("balance") === "number" ? (wallet.get("balance") as number) : 0;
    if (balance < total) {
      throw new HttpsError(
        "failed-precondition",
        `Your wallet balance (RM ${balance.toFixed(2)}) is lower than the total ` +
        `(RM ${total.toFixed(2)}). Top up your wallet to place this order.`,
      );
    }
    postEntry(tx, uid, wallet, {
      type: "payment", amount: -total, orderId: orderRef.id,
      description: `Payment for order #${number}`,
    });
    tx.set(counterRef, { value: number });
    lines.forEach((line, index) => tx.update(inventoryRefs[index], {
      stock: FieldValue.increment(-line.quantity),
    }));
    tx.create(orderRef, {
      number, customerId: uid, customerName: user.get("name") ?? "",
      customerPhone: user.get("phone") ?? "", branchId,
      branchName: branch.get("name") ?? "", branchAddress: branch.get("address") ?? "",
      isDelivery: fulfilment === "delivery", items, subtotal, deliveryFee,
      discount, total, walletPaid: total,
      ...(address?.exists ? { address: address.get("line"), addressLocation: address.get("location") } : {}),
      ...(customerNote ? { customerNote } : {}),
      ...(promoCode ? { promoCode } : {}),
      collectionCode: code, stockReserved: true, status: "pending",
      placedAt: FieldValue.serverTimestamp(), statusSince: FieldValue.serverTimestamp(),
    });
    return { orderId: orderRef.id };
  });
});

export const cancelOrder = onCall({ region: "asia-southeast1" }, async (request) => {
  const uid = customerUid(request.auth?.uid);
  const id = string(object(request.data).orderId, "order", 128);
  const profile = await db.doc(`users/${uid}`).get();
  const isAdmin = profile.get("role") === "storeAdmin" && profile.get("isActive") !== false;
  const ref = db.doc(`orders/${id}`);
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists) return { cancelled: false };
    const owner = order.get("customerId") === uid && profile.get("role") === "customer";
    const status = order.get("status");
    if ((!owner && !isAdmin) || status === "completed" || status === "cancelled" ||
        (owner && status !== "pending")) {
      return { cancelled: false };
    }
    // What the order holds now: the ordered items, or what is left of them
    // after shortages were reconciled when packing finished.
    const items = reservedLines(order);
    const inventoryRefs = order.get("stockReserved") === true && order.get("stockReleased") !== true
      ? items.map((item) => db.doc(`branches/${order.get("branchId")}/inventory/${item.productId}`))
      : [];
    const inventories = await Promise.all(inventoryRefs.map((item) => tx.get(item)));
    inventories.forEach((inventory, index) => {
      if (inventory.exists) tx.update(inventoryRefs[index], {
        stock: FieldValue.increment(items[index].quantity),
      });
    });
    tx.update(ref, {
      status: "cancelled", statusSince: FieldValue.serverTimestamp(),
      ...(inventoryRefs.length ? { stockReleased: true } : {}),
    });
    return { cancelled: true };
  });
});

export const createStaff = onCall({ region: "asia-southeast1" }, async (request) => {
  await requireAdmin(request.auth?.uid);
  const data = object(request.data);
  const name = string(data.name, "name");
  const email = string(data.email, "email", 254).toLowerCase();
  const phone = string(data.phone, "phone", 30);
  const password = string(data.temporaryPassword, "password", 128);
  const workerRole = data.workerRole;
  if (workerRole !== "packingStaff" && workerRole !== "deliveryDriver") {
    throw new HttpsError("invalid-argument", "Invalid worker role.");
  }
  const branchId = workerRole === "packingStaff" ? string(data.branchId, "branch", 100) : null;
  if (branchId && !(await db.doc(`branches/${branchId}`).get()).exists) {
    throw new HttpsError("invalid-argument", "Unknown branch.");
  }
  let account;
  try {
    account = await getAuth().createUser({ email, password, displayName: name, disabled: true });
  } catch (error) {
    const code = (error as { code?: string }).code;
    if (code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "An account with this email already exists.");
    }
    if (code === "auth/invalid-email" || code === "auth/invalid-password") {
      throw new HttpsError("invalid-argument", "Check the email and temporary password.");
    }
    throw error;
  }
  const profileRef = db.doc(`users/${account.uid}`);
  try {
    await profileRef.create({
      name, email, phone, role: "storeWorker", workerRole, branchId,
      isActive: true, joinedAt: FieldValue.serverTimestamp(), createdAt: FieldValue.serverTimestamp(),
    });
    await getAuth().updateUser(account.uid, { disabled: false });
    return { uid: account.uid };
  } catch (error) {
    await profileRef.delete();
    await getAuth().deleteUser(account.uid);
    throw error;
  }
});

export const setStaffActive = onCall({ region: "asia-southeast1" }, async (request) => {
  await requireAdmin(request.auth?.uid);
  const data = object(request.data);
  const uid = string(data.uid, "worker", 128);
  if (typeof data.isActive !== "boolean") {
    throw new HttpsError("invalid-argument", "Invalid account state.");
  }
  const profile = await db.doc(`users/${uid}`).get();
  if (profile.get("role") !== "storeWorker") {
    throw new HttpsError("failed-precondition", "Worker account not found.");
  }
  // Disable first so a deactivated worker cannot act while profile updates.
  if (!data.isActive) await getAuth().updateUser(uid, { disabled: true });
  await profile.ref.update({ isActive: data.isActive });
  if (data.isActive) await getAuth().updateUser(uid, { disabled: false });
  return { uid, isActive: data.isActive };
});
