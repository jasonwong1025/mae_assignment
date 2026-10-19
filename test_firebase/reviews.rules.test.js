import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

// A valid review of delivery order "o-done", written by Alice.
function review(overrides = {}) {
  return {
    orderNumber: 2301,
    branchId: "ss15",
    customerId: ALICE.uid,
    customerName: "Aisha",
    shoppingScore: 5,
    productScore: 4,
    deliveryScore: 3,
    driverId: "driver-1",
    driverName: "Amir Hamzah",
    comment: "Fast and fresh",
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

function withoutDelivery(data) {
  const { deliveryScore, driverId, driverName, ...rest } = data;
  return rest;
}

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    const base = {
      number: 2301,
      customerId: ALICE.uid,
      branchId: "ss15",
      items: [],
      total: 0,
    };
    await setDoc(doc(db, "orders", "o-done"), {
      ...base,
      isDelivery: true,
      status: "completed",
      driverId: "driver-1",
      driverName: "Amir Hamzah",
    });
    await setDoc(doc(db, "orders", "o-pickup"), {
      ...base,
      isDelivery: false,
      status: "completed",
    });
    await setDoc(doc(db, "orders", "o-pending"), {
      ...base,
      isDelivery: true,
      status: "pending",
    });
    await setDoc(doc(db, "reviews", "o-rated"), {
      orderNumber: 1,
      branchId: "ss15",
      customerId: ALICE.uid,
      customerName: "Aisha",
      shoppingScore: 5,
      productScore: 5,
      createdAt: new Date(),
    });
  });
});

const alice = () => firestoreForUser(testEnv, ALICE.uid, ALICE.email);

describe("writing a review", () => {
  test("the customer can rate their completed delivery order", async () => {
    await assertSucceeds(setDoc(doc(alice(), "reviews", "o-done"), review()));
  });

  test("a pickup order is rated without a delivery score", async () => {
    await assertSucceeds(
      setDoc(doc(alice(), "reviews", "o-pickup"), withoutDelivery(review()))
    );
  });

  test("a pickup order cannot carry a delivery score", async () => {
    await assertFails(setDoc(doc(alice(), "reviews", "o-pickup"), review()));
  });

  test("a delivery order needs a delivery score", async () => {
    await assertFails(
      setDoc(doc(alice(), "reviews", "o-done"), withoutDelivery(review()))
    );
  });

  test("a delivery review carries the order's driver", async () => {
    await assertFails(
      setDoc(
        doc(alice(), "reviews", "o-done"),
        review({ driverId: "someone-else" })
      )
    );
    await assertFails(
      setDoc(
        doc(alice(), "reviews", "o-done"),
        review({ driverName: "Someone Else" })
      )
    );
    const { driverId, driverName, ...noDriver } = review();
    await assertFails(setDoc(doc(alice(), "reviews", "o-done"), noDriver));
  });

  test("a pickup review cannot name a driver", async () => {
    await assertFails(
      setDoc(
        doc(alice(), "reviews", "o-pickup"),
        { ...withoutDelivery(review()), driverId: "driver-1" }
      )
    );
  });

  test("the comment is optional", async () => {
    const { comment, ...noComment } = review();
    await assertSucceeds(setDoc(doc(alice(), "reviews", "o-done"), noComment));
  });

  test("an order that is not completed cannot be rated", async () => {
    await assertFails(setDoc(doc(alice(), "reviews", "o-pending"), review()));
  });

  test("a missing order cannot be rated", async () => {
    await assertFails(setDoc(doc(alice(), "reviews", "nope"), review()));
  });

  test("someone else's order cannot be rated", async () => {
    const bob = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(
      setDoc(doc(bob, "reviews", "o-done"), review({ customerId: BOB.uid }))
    );
    await assertFails(setDoc(doc(bob, "reviews", "o-done"), review()));
  });

  test("scores must be whole numbers from 1 to 5", async () => {
    for (const bad of [0, 6, 3.5, "5"]) {
      await assertFails(
        setDoc(doc(alice(), "reviews", "o-done"), review({ shoppingScore: bad }))
      );
    }
    await assertFails(
      setDoc(doc(alice(), "reviews", "o-done"), review({ deliveryScore: 0 }))
    );
  });

  test("the order number and branch must match the order", async () => {
    await assertFails(
      setDoc(doc(alice(), "reviews", "o-done"), review({ orderNumber: 1 }))
    );
    await assertFails(
      setDoc(doc(alice(), "reviews", "o-done"), review({ branchId: "other" }))
    );
  });

  test("the comment is capped at 500 characters", async () => {
    await assertFails(
      setDoc(
        doc(alice(), "reviews", "o-done"),
        review({ comment: "x".repeat(501) })
      )
    );
    await assertSucceeds(
      setDoc(
        doc(alice(), "reviews", "o-done"),
        review({ comment: "x".repeat(500) })
      )
    );
  });

  test("unknown fields are rejected", async () => {
    await assertFails(
      setDoc(doc(alice(), "reviews", "o-done"), review({ approved: true }))
    );
  });

  test("createdAt must be the server time", async () => {
    await assertFails(
      setDoc(
        doc(alice(), "reviews", "o-done"),
        review({ createdAt: new Date(0) })
      )
    );
  });

  test("a guest cannot write a review", async () => {
    await assertFails(
      setDoc(doc(firestoreForGuest(testEnv), "reviews", "o-done"), review())
    );
  });
});

describe("reviews are immutable", () => {
  test("a review cannot be edited or deleted", async () => {
    await assertFails(
      updateDoc(doc(alice(), "reviews", "o-rated"), { shoppingScore: 1 })
    );
    await assertFails(deleteDoc(doc(alice(), "reviews", "o-rated")));
  });
});

describe("reading reviews", () => {
  test("the owner can read their review", async () => {
    await assertSucceeds(getDoc(doc(alice(), "reviews", "o-rated")));
  });

  test("the owner can check an order that is not rated yet", async () => {
    await assertSucceeds(getDoc(doc(alice(), "reviews", "o-done")));
  });

  test("another customer cannot read the review", async () => {
    const bob = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(getDoc(doc(bob, "reviews", "o-rated")));
  });

  test("staff can read any review", async () => {
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertSucceeds(getDoc(doc(admin, "reviews", "o-rated")));
  });

  test("a guest cannot read reviews", async () => {
    await assertFails(
      getDoc(doc(firestoreForGuest(testEnv), "reviews", "o-rated"))
    );
  });
});
