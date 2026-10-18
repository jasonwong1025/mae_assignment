import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  deleteDoc,
} from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const WORKER = { uid: "worker", email: "worker@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

// A valid order payload owned by `customerId`, with a server-set placedAt.
function orderFor(customerId) {
  return {
    number: 2301,
    customerId,
    customerName: "Aisha",
    branchId: "ss15",
    isDelivery: true,
    items: [{ productId: "p1", quantity: 1, unitPrice: 8.9 }],
    subtotal: 8.9,
    deliveryFee: 3,
    discount: 0,
    total: 11.9,
    status: "pending",
    placedAt: serverTimestamp(),
    statusSince: serverTimestamp(),
  };
}

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  // Seed user profiles (so isStaff resolves) and one existing order.
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", WORKER.uid), { role: "storeWorker" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(doc(db, "orders", "o-alice"), {
      number: 1,
      customerId: ALICE.uid,
      branchId: "ss15",
      items: [],
      total: 0,
      status: "pending",
    });
  });
});

describe("placing orders", () => {
  test("a customer can create their own order", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      setDoc(doc(db, "orders", "o-new"), orderFor(ALICE.uid))
    );
  });

  test("a customer cannot create an order for someone else", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "orders", "o-forged"), orderFor(BOB.uid))
    );
  });

  test("an order cannot be created already in packing", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    const forged = { ...orderFor(ALICE.uid), status: "packing" };
    await assertFails(setDoc(doc(db, "orders", "o-jump"), forged));
  });

  test("a guest cannot create an order", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(
      setDoc(doc(db, "orders", "o-guest"), orderFor("someone"))
    );
  });
});

describe("reading orders", () => {
  test("the owner can read their own order", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(doc(db, "orders", "o-alice")));
  });

  test("another customer cannot read someone else's order", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(getDoc(doc(db, "orders", "o-alice")));
  });

  test("a worker can read any order", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertSucceeds(getDoc(doc(db, "orders", "o-alice")));
  });

  test("an admin can read any order", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertSucceeds(getDoc(doc(db, "orders", "o-alice")));
  });
});

describe("updating orders", () => {
  test("a worker can advance the status", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertSucceeds(
      updateDoc(doc(db, "orders", "o-alice"), { status: "packing" })
    );
  });

  test("the customer cannot change their order's status", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { status: "completed" })
    );
  });

  test("nobody can delete an order", async () => {
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(deleteDoc(doc(admin, "orders", "o-alice")));
  });
});
