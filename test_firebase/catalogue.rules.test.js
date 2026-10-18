import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  // Seed a product, a category, a branch and its inventory with rules off.
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "products", "p1"), {
      name: "Apple",
      brand: "Fuji",
      categoryId: "produce",
    });
    await setDoc(doc(db, "categories", "produce"), {
      name: "Fresh produce",
      sortOrder: 0,
    });
    await setDoc(doc(db, "branches", "ss15"), { name: "SS15 Subang" });
    await setDoc(doc(db, "branches", "ss15", "inventory", "p1"), {
      price: 3.5,
      stock: 20,
      isHidden: false,
    });
  });
});

describe("catalogue reads", () => {
  test("a signed-in customer can read products", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(doc(db, "products", "p1")));
  });

  test("a signed-in customer can read categories", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(doc(db, "categories", "produce")));
  });

  test("a signed-in customer can read a branch's inventory", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      getDoc(doc(db, "branches", "ss15", "inventory", "p1"))
    );
  });

  test("a guest cannot read the catalogue", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(doc(db, "products", "p1")));
    await assertFails(getDoc(doc(db, "categories", "produce")));
    await assertFails(
      getDoc(doc(db, "branches", "ss15", "inventory", "p1"))
    );
  });
});

describe("catalogue writes are denied from the client", () => {
  test("a customer cannot create or edit a product", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "products", "p2"), { name: "Injected" })
    );
    await assertFails(
      setDoc(doc(db, "products", "p1"), { name: "Tampered" })
    );
  });

  test("a customer cannot change inventory price or stock", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "branches", "ss15", "inventory", "p1"), {
        price: 0.01,
        stock: 999,
      })
    );
  });
});
