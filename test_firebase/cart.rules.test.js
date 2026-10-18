import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, deleteDoc, serverTimestamp } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

function cart(overrides = {}) {
  return {
    lines: [{ productId: "p1", quantity: 2 }],
    fulfilment: "delivery",
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

const cartRef = (db, uid, id = "current") => doc(db, "users", uid, "cart", id);

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(cartRef(db, ALICE.uid), {
      lines: [{ productId: "p1", quantity: 1 }],
      fulfilment: "pickup",
      updatedAt: new Date(),
    });
  });
});

describe("saved cart is private to the owner", () => {
  test("the owner can read their own cart", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(cartRef(db, ALICE.uid)));
  });

  test("the owner can create, update and delete their cart", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertSucceeds(setDoc(cartRef(db, BOB.uid), cart()));
    await assertSucceeds(
      setDoc(cartRef(db, BOB.uid), cart({ promoCode: "FRESH5" }))
    );
    await assertSucceeds(deleteDoc(cartRef(db, BOB.uid)));
  });

  test("another customer cannot read or write someone's cart", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(getDoc(cartRef(db, ALICE.uid)));
    await assertFails(setDoc(cartRef(db, ALICE.uid), cart()));
    await assertFails(deleteDoc(cartRef(db, ALICE.uid)));
  });

  test("not even the admin can read a customer's cart", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(getDoc(cartRef(db, ALICE.uid)));
  });

  test("a guest cannot read or write a cart", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(cartRef(db, ALICE.uid)));
    await assertFails(setDoc(cartRef(db, ALICE.uid), cart()));
  });
});

describe("saved cart shape is validated", () => {
  const bob = () => firestoreForUser(testEnv, BOB.uid, BOB.email);

  test("only the 'current' document is allowed", async () => {
    await assertFails(setDoc(cartRef(bob(), BOB.uid, "other"), cart()));
  });

  test("rejects unknown fields", async () => {
    await assertFails(setDoc(cartRef(bob(), BOB.uid), cart({ extra: 1 })));
  });

  test("requires lines, fulfilment and updatedAt", async () => {
    await assertFails(
      setDoc(cartRef(bob(), BOB.uid), {
        fulfilment: "delivery",
        updatedAt: serverTimestamp(),
      })
    );
  });

  test("rejects an unknown fulfilment method", async () => {
    await assertFails(
      setDoc(cartRef(bob(), BOB.uid), cart({ fulfilment: "drone" }))
    );
  });

  test("rejects lines that are not a list", async () => {
    await assertFails(
      setDoc(cartRef(bob(), BOB.uid), cart({ lines: "p1" }))
    );
  });

  test("rejects more than 100 lines", async () => {
    const lines = Array.from({ length: 101 }, (_, i) => ({
      productId: `p${i}`,
      quantity: 1,
    }));
    await assertFails(setDoc(cartRef(bob(), BOB.uid), cart({ lines })));
  });

  test("updatedAt must be the server time", async () => {
    await assertFails(
      setDoc(cartRef(bob(), BOB.uid), cart({ updatedAt: new Date(0) }))
    );
  });
});
