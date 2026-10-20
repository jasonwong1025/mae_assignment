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

async function fund(user, balance) {
  await db.doc(`users/${user.uid}/wallet/current`).set({ balance });
}
async function balanceOf(user) {
  return (await db.doc(`users/${user.uid}/wallet/current`).get()).get("balance");
}
async function entriesOf(user) {
  const snapshot = await db.collection(`users/${user.uid}/walletTransactions`).get();
  return snapshot.docs.map((doc) => doc.data()).sort((a, b) => a.balanceAfter - b.balanceAfter);
}
/** Waits for a Firestore trigger to have done its work. */
async function until(check, what = "the trigger") {
  for (let attempt = 0; attempt < 60; attempt++) {
    const value = await check();
    if (value) return value;
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error(`Timed out waiting for ${what}`);
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
  await fund(customer, 500);
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
    await fund(secondCustomer, 500);
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

describe("wallet", () => {
  test("a top up adds to the balance and the history", async () => {
    const result = await call("topUpWallet", { amount: 50, method: "Simulated card" }, customer.token);
    expect(result.status).toBe(200);
    expect(result.body.result.balance).toBe(550);
    expect(await balanceOf(customer)).toBe(550);
    const entries = await entriesOf(customer);
    expect(entries).toHaveLength(1);
    expect(entries[0]).toMatchObject({ type: "topUp", amount: 50, balanceAfter: 550 });
  });

  test("a top up creates the wallet for a new customer", async () => {
    const fresh = await signUp("customer", "Fresh");
    const result = await call("topUpWallet", { amount: 20 }, fresh.token);
    expect(result.body.result.balance).toBe(20);
  });

  test("rejects bad amounts, other roles and guests", async () => {
    for (const amount of [0, -5, 501, 10.005, "50", null]) {
      expect((await call("topUpWallet", { amount }, customer.token)).status).toBe(400);
    }
    expect((await call("topUpWallet", { amount: 10 }, admin.token)).status).toBe(403);
    expect((await call("topUpWallet", { amount: 10 })).status).toBe(401);
    expect(await balanceOf(customer)).toBe(500);
  });

  test("a wallet cannot hold more than the limit", async () => {
    await fund(customer, 1900);
    const result = await call("topUpWallet", { amount: 200 }, customer.token);
    expect(result.status).toBe(400);
    expect(await balanceOf(customer)).toBe(1900);
  });

  test("placing an order pays from the wallet, once", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    expect(placed.status).toBe(200);
    expect(await balanceOf(customer)).toBe(482.2);
    const order = await db.doc(`orders/${placed.body.result.orderId}`).get();
    expect(order.get("walletPaid")).toBe(17.8);
    const [payment] = await entriesOf(customer);
    expect(payment).toMatchObject({
      type: "payment", amount: -17.8, orderId: order.id, balanceAfter: 482.2,
    });
  });

  test("an order the wallet cannot cover is refused and nothing changes", async () => {
    await fund(customer, 10);
    const result = await call("placeOrder", pickup, customer.token);
    expect(result.status).toBe(400);
    expect(result.body.error.message).toContain("Top up your wallet");
    expect(await balanceOf(customer)).toBe(10);
    expect((await db.doc("branches/ss15/inventory/p1").get()).get("stock")).toBe(3);
    expect((await db.collection("orders").get()).size).toBe(0);
  });

  test("a customer with no wallet cannot order", async () => {
    const fresh = await signUp("customer", "Broke");
    const result = await call("placeOrder", pickup, fresh.token);
    expect(result.status).toBe(400);
  });

  test("cancelling refunds the payment once", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderId = placed.body.result.orderId;
    await call("cancelOrder", { orderId }, customer.token);
    await until(async () => (await balanceOf(customer)) === 500, "the refund");
    const entries = await entriesOf(customer);
    expect(entries.map((entry) => entry.type).sort()).toEqual(["payment", "refund"]);
    // Cancelling again changes nothing.
    await call("cancelOrder", { orderId }, customer.token);
    await new Promise((resolve) => setTimeout(resolve, 1000));
    expect(await balanceOf(customer)).toBe(500);
    expect((await db.doc(`orders/${orderId}`).get()).get("walletPaid")).toBe(0);
  });

  test("an admin cancelling a waiting order also refunds it and frees the stock", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    // The admin app cancels with a plain write.
    await orderRef.update({ status: "cancelled" });
    await until(async () => (await balanceOf(customer)) === 500, "the refund");
    await until(
      async () => (await db.doc("branches/ss15/inventory/p1").get()).get("stock") === 3,
      "the stock",
    );
  });

  test("a removed item is refunded when packing finishes, once", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({
      status: "packing",
      shortages: { p1: { status: "removed" } },
    });
    await orderRef.update({ status: "ready" });
    await until(async () => (await balanceOf(customer)) === 500, "the refund");
    expect((await orderRef.get()).get("walletSettled")).toBe(true);
    expect((await orderRef.get()).get("walletPaid")).toBe(0);
    // The same order moving on does not settle again.
    await orderRef.update({ status: "completed" });
    await new Promise((resolve) => setTimeout(resolve, 1000));
    expect(await balanceOf(customer)).toBe(500);
  });

  test("a dearer accepted replacement is charged when packing finishes", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({
      status: "packing",
      shortages: {
        p1: {
          status: "accepted",
          replacement: { lineId: "p1", productId: "p2", unitPrice: 10.9, quantity: 2 },
        },
      },
    });
    await orderRef.update({ status: "ready" });
    // 2 x 10.90 = 21.80 against 17.80 paid.
    await until(async () => (await balanceOf(customer)) === 478.2, "the charge");
    const entries = await entriesOf(customer);
    expect(entries.map((entry) => entry.type).sort()).toEqual(["adjustment", "payment"]);
  });

  describe("a dearer replacement when the balance is short", () => {
    // 2 x 10.90 = 21.80 against 17.80 paid: RM 4.00 more.
    const dearer = {
      status: "accepted",
      replacement: { lineId: "p1", productId: "p2", unitPrice: 10.9, quantity: 2 },
    };

    async function settleWithBalance(balance) {
      const placed = await call("placeOrder", pickup, customer.token);
      const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
      await orderRef.update({ status: "packing", shortages: { p1: dearer } });
      // The customer spends the rest of the wallet before packing finishes.
      await fund(customer, balance);
      await orderRef.update({ status: "ready" });
      await until(async () => (await orderRef.get()).get("walletSettled") === true, "settlement");
      return orderRef;
    }

    test("charges only what is there and waives the rest, never going below zero", async () => {
      const orderRef = await settleWithBalance(3);
      expect(await balanceOf(customer)).toBe(0);
      const order = await orderRef.get();
      expect(order.get("walletWaived")).toBe(1);
      expect(order.get("walletPaid")).toBe(20.8);
      const adjustment = (await entriesOf(customer)).find((entry) => entry.type === "adjustment");
      expect(adjustment.amount).toBe(-3);
      expect(adjustment.description).toContain("RM 1.00 waived");
    });

    test("an empty wallet is not charged at all", async () => {
      const orderRef = await settleWithBalance(0);
      expect(await balanceOf(customer)).toBe(0);
      const order = await orderRef.get();
      expect(order.get("walletWaived")).toBe(4);
      expect(order.get("walletPaid")).toBe(17.8);
      expect((await entriesOf(customer)).filter((entry) => entry.type === "adjustment")).toHaveLength(0);
    });

    test("a wallet that is already below zero counts as empty", async () => {
      const orderRef = await settleWithBalance(-5);
      expect(await balanceOf(customer)).toBe(-5);
      expect((await orderRef.get()).get("walletWaived")).toBe(4);
    });

    test("a balance that exactly covers the difference is charged in full", async () => {
      const orderRef = await settleWithBalance(4);
      expect(await balanceOf(customer)).toBe(0);
      const order = await orderRef.get();
      expect(order.get("walletWaived")).toBeUndefined();
      expect(order.get("walletPaid")).toBe(21.8);
    });

    test("cancelling afterwards refunds only what was really paid", async () => {
      const orderRef = await settleWithBalance(3);
      await orderRef.update({ status: "cancelled" });
      await until(async () => (await orderRef.get()).get("walletPaid") === 0, "the refund");
      // 3 charged + 17.80 paid = 20.80 back; the waived RM 1.00 was never taken.
      expect(await balanceOf(customer)).toBe(20.8);
    });

    test("a refund is never held back, whatever the balance", async () => {
      const placed = await call("placeOrder", pickup, customer.token);
      const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
      await orderRef.update({ status: "packing", shortages: { p1: { status: "removed" } } });
      await fund(customer, -5);
      await orderRef.update({ status: "ready" });
      await until(async () => (await balanceOf(customer)) === 12.8, "the refund");
    });
  });

  test("an order without shortages settles to nothing", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    await orderRef.update({ status: "ready" });
    await until(async () => (await orderRef.get()).get("walletSettled") === true, "settlement");
    expect(await balanceOf(customer)).toBe(482.2);
    expect(await entriesOf(customer)).toHaveLength(1);
  });

  test("a cancelled order after settlement refunds what is still held", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing", shortages: { p1: { status: "removed" } } });
    await orderRef.update({ status: "ready" });
    await until(async () => (await orderRef.get()).get("walletSettled") === true, "settlement");
    await orderRef.update({ status: "cancelled" });
    await new Promise((resolve) => setTimeout(resolve, 1000));
    // Everything was already refunded, so nothing more is paid back.
    expect(await balanceOf(customer)).toBe(500);
  });
});

describe("notifications", () => {
  const inboxOf = async (user) => {
    const snapshot = await db.collection(`users/${user.uid}/notifications`).get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  };

  test("the customer is told as the order moves along", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    await orderRef.update({ status: "ready" });
    const messages = await until(async () => {
      const found = await inboxOf(customer);
      return found.length >= 2 ? found : null;
    }, "two notifications");
    const titles = messages.map((message) => message.title).join(" | ");
    expect(titles).toContain("Packing started");
    expect(titles).toContain("ready for pickup");
    expect(messages.every((message) => message.read === false)).toBe(true);
    expect(messages.every((message) => message.orderId === orderRef.id)).toBe(true);
  });

  test("a delivery order says a driver will collect it", async () => {
    const placed = await call("placeOrder", {
      ...pickup, fulfilment: "delivery", addressId: "home",
    }, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    await orderRef.update({ status: "ready" });
    await orderRef.update({ status: "outForDelivery" });
    await orderRef.update({ status: "completed" });
    const messages = await until(async () => {
      const found = await inboxOf(customer);
      return found.length >= 4 ? found : null;
    }, "four notifications");
    const text = messages.map((message) => `${message.title} ${message.body}`).join(" | ");
    expect(text).toContain("A driver will collect it");
    expect(text).toContain("on the way");
    expect(text).toContain("delivered");
  });

  test("an open replacement asks the customer to reply", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    await orderRef.update({
      shortages: { p1: { status: "proposed", replacement: { lineId: "p1", unitPrice: 5, quantity: 2 } } },
      openShortages: 1,
    });
    const messages = await until(async () => {
      const found = (await inboxOf(customer)).filter((m) => m.title.includes("reply is needed"));
      return found.length ? found : null;
    }, "the reply request");
    expect(messages[0].body).toContain("replacement");
  });

  test("a cancelled order tells the customer about the refund", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    await call("cancelOrder", { orderId: placed.body.result.orderId }, customer.token);
    const messages = await until(async () => {
      const found = (await inboxOf(customer)).filter((m) => m.title.includes("cancelled"));
      return found.length ? found : null;
    }, "the cancel notice");
    expect(messages[0].body).toContain("refunded");
  });

  test("a packer and a driver are told when an order is assigned to them", async () => {
    const packer = await signUp("storeWorker", "Packer");
    const driver = await signUp("storeWorker", "Driver");
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ packerId: packer.uid, driverId: driver.uid });
    const [packerMessages, driverMessages] = await until(async () => {
      const both = [await inboxOf(packer), await inboxOf(driver)];
      return both[0].length && both[1].length ? both : null;
    }, "assignment notices");
    expect(packerMessages[0].title).toBe("New order to pack");
    expect(driverMessages[0].title).toBe("New delivery");
  });

  test("a change that is not news sends nothing, and nobody is told twice", async () => {
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    await until(async () => (await inboxOf(customer)).length === 1, "the first notice");
    await orderRef.update({ customerNote: "Please bag the milk separately" });
    await new Promise((resolve) => setTimeout(resolve, 1000));
    expect(await inboxOf(customer)).toHaveLength(1);
  });

  test("a registered phone does not break the update when push fails", async () => {
    await db.doc(`users/${customer.uid}/devices/fake-token`).set({ platform: "android" });
    const placed = await call("placeOrder", pickup, customer.token);
    const orderRef = db.doc(`orders/${placed.body.result.orderId}`);
    await orderRef.update({ status: "packing" });
    const messages = await until(async () => {
      const found = await inboxOf(customer);
      return found.length ? found : null;
    }, "the notice");
    expect(messages[0].title).toContain("Packing started");
  });
});
