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

  test("a customer cannot create an order carrying fulfilment fields", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "orders", "o-sneaky"), {
        ...orderFor(ALICE.uid),
        packerId: "w1",
      })
    );
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

  test("a worker can record fulfilment fields with the status", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertSucceeds(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "packing",
        statusSince: serverTimestamp(),
        packedLineIds: ["L1"],
        packingStartedAt: serverTimestamp(),
      })
    );
  });

  test("a worker cannot change checkout fields", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { total: 0.01 })
    );
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { customerId: WORKER.uid })
    );
  });

  test("a worker cannot assign packers or drivers", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { driverId: WORKER.uid })
    );
  });

  test("a worker cannot set an unknown status", async () => {
    const db = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { status: "teleported" })
    );
  });

  test("an admin can assign a driver and a packer", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertSucceeds(
      updateDoc(doc(db, "orders", "o-alice"), {
        driverId: "w7",
        driverName: "Amir",
        driverAssignedAt: serverTimestamp(),
        packerId: "w1",
        packerName: "Daniel",
        packerAssignedAt: serverTimestamp(),
        dueAt: serverTimestamp(),
      })
    );
  });

  test("an admin cannot change checkout fields", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { total: 0.01 })
    );
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { items: [{ productId: "p9", quantity: 1 }] })
    );
  });

  test("an admin cannot write the worker's fulfilment fields", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { proofPhotoUrl: "https://x" })
    );
  });

  test("the customer cannot change their order's status", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), { status: "completed" })
    );
  });

  test("the owner can cancel a pending order", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("the owner cannot cancel once packing has started", async () => {
    await seed(testEnv, async (db) => {
      await setDoc(doc(db, "orders", "o-packing"), {
        number: 2,
        customerId: ALICE.uid,
        branchId: "ss15",
        items: [],
        total: 0,
        status: "packing",
      });
    });
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-packing"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("a cancel cannot change anything else on the order", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
        total: 0.01,
      })
    );
  });

  test("a cancel must use the server time", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "cancelled",
        statusSince: new Date(0),
      })
    );
  });

  test("another customer cannot cancel someone else's order", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("the owner cannot move their order to any other status", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "orders", "o-alice"), {
        status: "packing",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("nobody can delete an order", async () => {
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(deleteDoc(doc(admin, "orders", "o-alice")));
  });
});
