import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, deleteDoc, serverTimestamp } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

function list(overrides = {}) {
  return {
    items: [{ id: "a", name: "fresh milk", quantity: 2 }],
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

const listRef = (db, uid, id = "current") =>
  doc(db, "users", uid, "groceryList", id);

let testEnv;

beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(listRef(db, ALICE.uid), {
      items: [{ id: "x", name: "eggs", quantity: 1 }],
      updatedAt: new Date(),
    });
  });
});

describe("grocery list is private to the owner", () => {
  test("the owner can read their own list", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(listRef(db, ALICE.uid)));
  });

  test("the owner can create, update and delete their list", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertSucceeds(setDoc(listRef(db, BOB.uid), list()));
    await assertSucceeds(
      setDoc(
        listRef(db, BOB.uid),
        list({ items: [{ id: "b", name: "rice", quantity: 1, productId: "p1" }] })
      )
    );
    await assertSucceeds(deleteDoc(listRef(db, BOB.uid)));
  });

  test("another customer or the admin cannot read or write it", async () => {
    const bob = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(getDoc(listRef(bob, ALICE.uid)));
    await assertFails(setDoc(listRef(bob, ALICE.uid), list()));
    await assertFails(deleteDoc(listRef(bob, ALICE.uid)));
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(getDoc(listRef(admin, ALICE.uid)));
  });

  test("a guest has no access", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(listRef(db, ALICE.uid)));
    await assertFails(setDoc(listRef(db, ALICE.uid), list()));
  });
});

describe("grocery list shape", () => {
  const bob = () => firestoreForUser(testEnv, BOB.uid, BOB.email);

  test("only the one document called current", async () => {
    await assertFails(setDoc(listRef(bob(), BOB.uid, "other"), list()));
  });

  test("no extra fields, and both fields are required", async () => {
    await assertFails(setDoc(listRef(bob(), BOB.uid), list({ note: "hi" })));
    await assertFails(
      setDoc(listRef(bob(), BOB.uid), { updatedAt: serverTimestamp() })
    );
    await assertFails(setDoc(listRef(bob(), BOB.uid), { items: [] }));
  });

  test("items must be a list of at most 100", async () => {
    await assertFails(setDoc(listRef(bob(), BOB.uid), list({ items: "milk" })));
    const many = Array.from({ length: 101 }, (_, i) => ({
      id: `i${i}`,
      name: "x",
      quantity: 1,
    }));
    await assertFails(setDoc(listRef(bob(), BOB.uid), list({ items: many })));
    await assertSucceeds(
      setDoc(listRef(bob(), BOB.uid), list({ items: many.slice(0, 100) }))
    );
  });

  test("the time must be the server time", async () => {
    await assertFails(
      setDoc(listRef(bob(), BOB.uid), list({ updatedAt: new Date(2020, 0, 1) }))
    );
  });
});
