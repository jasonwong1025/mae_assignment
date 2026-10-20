import { beforeEach, describe, expect, test } from "vitest";
import { initializeApp, getApps } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { GeoPoint, getFirestore } from "firebase-admin/firestore";

const projectId = "mae-assignment-grocerly";
if (!getApps().length) initializeApp({ projectId });
const db = getFirestore();
let serial = 0;
let customer;
let admin;

async function signUp(role, label) {
  const email = `${label}-${++serial}@example.test`;
  const response = await fetch(
    "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key",
    {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ email, password: "Password123!", returnSecureToken: true }),
    }
  );
  const account = await response.json();
  if (!response.ok) throw new Error(JSON.stringify(account));
  await db.doc(`users/${account.localId}`).set({
    role, name: label, email, phone: "0123456789", isActive: true,
  });
  return { uid: account.localId, token: account.idToken };
}

async function call(name, data, token) {
  const response = await fetch(
    `http://127.0.0.1:5001/${projectId}/asia-southeast1/${name}`,
    {
      method: "POST",
      headers: {
        "content-type": "application/json",
        ...(token ? { authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify({ data }),
    }
  );
  return { status: response.status, body: await response.json() };
}

beforeEach(async () => {
  customer = await signUp("customer", "Customer");
  admin = await signUp("storeAdmin", "Admin");
  await db.doc("branches/ss15").set({
    name: "SS15 Subang", address: "1 Jalan SS15",
    location: new GeoPoint(3, 101), maxDeliveryKm: 10,
    baseDeliveryFee: 3, feePerKm: 1, isTemporarilyClosed: false,
  });
  await db.doc("products/p1").set({
    name: "Fresh milk", brand: "Farm", packSize: "1L", categoryId: "dairy",
  });
  await db.doc("branches/ss15/inventory/p1").set({
    price: 8.9, stock: 3, isHidden: false,
  });
  await db.doc(`users/${customer.uid}/addresses/home`).set({
    line: "12 Jalan Besar", location: new GeoPoint(3.001, 101.001),
  });
});

const pickup = {
  branchId: "ss15", fulfilment: "pickup",
  lines: [{ productId: "p1", quantity: 2 }],
};

describe("placeOrder", () => {
  test("prices from Firestore and reserves stock in the same transaction", async () => {
    const result = await call("placeOrder", {
      ...pickup, total: 0.01, promoCode: "FRESH5",
    }, customer.token);
    expect(result.status).toBe(200);
    const order = await db.doc(`orders/${result.body.result.orderId}`).get();
    expect(order.get("customerId")).toBe(customer.uid);
    expect(order.get("items")[0].unitPrice).toBe(8.9);
    expect(order.get("subtotal")).toBe(17.8);
    expect(order.get("discount")).toBe(5);
    expect(order.get("total")).toBe(12.8);
    expect(order.get("collectionCode")).toMatch(/^[ACDEFGHJKMNPQRTUVWXY3479]{8}$/);
    expect((await db.doc("branches/ss15/inventory/p1").get()).get("stock")).toBe(1);
  });

  test("rejects unauthenticated and non-customer callers", async () => {
    expect((await call("placeOrder", pickup)).status).toBe(401);
    expect((await call("placeOrder", pickup, admin.token)).status).toBe(403);
  });

  test("rejects insufficient stock without writing an order", async () => {
    const result = await call("placeOrder", {
      ...pickup, lines: [{ productId: "p1", quantity: 4 }],
    }, customer.token);
    expect(result.status).toBe(400);
    expect((await db.doc("branches/ss15/inventory/p1").get()).get("stock")).toBe(3);
  });

  test("concurrent checkouts cannot reserve the same stock twice", async () => {
    const secondCustomer = await signUp("customer", "Second");
    const results = await Promise.all([
      call("placeOrder", pickup, customer.token),
      call("placeOrder", pickup, secondCustomer.token),
    ]);
    expect(results.filter((result) => result.status === 200)).toHaveLength(1);
    expect(results.filter((result) => result.status !== 200)).toHaveLength(1);
    expect((await db.doc("branches/ss15/inventory/p1").get()).get("stock")).toBe(1);
  });

  test("delivery uses saved address and server-side distance fee", async () => {
    const result = await call("placeOrder", {
      ...pickup, fulfilment: "delivery", addressId: "home",
      deliveryFee: 0,
    }, customer.token);
    expect(result.status).toBe(200);
    const order = await db.doc(`orders/${result.body.result.orderId}`).get();
    expect(order.get("deliveryFee")).toBe(4);
    expect(order.get("address")).toBe("12 Jalan Besar");
  });

  test("cancellation releases reserved stock once", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderId = placed.body.result.orderId;
    expect((await call("cancelOrder", { orderId }, customer.token)).body.result.cancelled).toBe(true);
    expect((await call("cancelOrder", { orderId }, customer.token)).body.result.cancelled).toBe(false);
    expect((await db.doc("branches/ss15/inventory/p1").get()).get("stock")).toBe(3);
  });
});

describe("staff management", () => {
  test("only HQ admin creates Auth and worker profile", async () => {
    const input = {
      name: "Packer", email: `packer-${++serial}@example.test`,
      phone: "0123456789", temporaryPassword: "Password123!",
      workerRole: "packingStaff", branchId: "ss15",
    };
    expect((await call("createStaff", input, customer.token)).status).toBe(403);
    const result = await call("createStaff", input, admin.token);
    expect(result.status).toBe(200);
    const uid = result.body.result.uid;
    expect((await getAuth().getUser(uid)).disabled).toBe(false);
    expect((await db.doc(`users/${uid}`).get()).get("workerRole")).toBe("packingStaff");
    expect((await call("setStaffActive", { uid, isActive: false }, customer.token)).status).toBe(403);
    expect((await call("setStaffActive", { uid, isActive: false }, admin.token)).status).toBe(200);
    expect((await getAuth().getUser(uid)).disabled).toBe(true);
    expect((await db.doc(`users/${uid}`).get()).get("isActive")).toBe(false);
  });
});
