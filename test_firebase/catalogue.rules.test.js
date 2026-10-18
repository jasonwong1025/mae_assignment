import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };
const WORKER = { uid: "worker", email: "worker@example.com" };

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  // Seed a product, a category, a branch and its inventory with rules off.
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(doc(db, "users", WORKER.uid), { role: "storeWorker" });
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

describe("catalogue writes are denied to everyone but the admin", () => {
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

const admin = () => firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);

function product(overrides = {}) {
  return {
    name: "Banana",
    brand: "Dole",
    categoryId: "produce",
    packSize: "1kg",
    description: "Sweet",
    imageUrls: [],
    lowStockLevel: 5,
    ...overrides,
  };
}

describe("admin catalogue writes", () => {
  test("the admin can create and edit a product", async () => {
    await assertSucceeds(setDoc(doc(admin(), "products", "p2"), product()));
    await assertSucceeds(
      setDoc(doc(admin(), "products", "p2"), product({ name: "Banana 2" }))
    );
  });

  test("a store worker cannot write the catalogue", async () => {
    const worker = firestoreForUser(testEnv, WORKER.uid, WORKER.email);
    await assertFails(setDoc(doc(worker, "products", "p2"), product()));
    await assertFails(
      setDoc(doc(worker, "branches", "ss15", "inventory", "p1"), {
        price: 1,
        stock: 1,
        isHidden: false,
      })
    );
  });

  test("a product needs a name and a category", async () => {
    const { name, ...noName } = product();
    await assertFails(setDoc(doc(admin(), "products", "p2"), noName));
    const { categoryId, ...noCategory } = product();
    await assertFails(setDoc(doc(admin(), "products", "p2"), noCategory));
    await assertFails(
      setDoc(doc(admin(), "products", "p2"), product({ name: "" }))
    );
  });

  test("a product rejects unknown fields and bad values", async () => {
    await assertFails(
      setDoc(doc(admin(), "products", "p2"), product({ price: 1 }))
    );
    await assertFails(
      setDoc(doc(admin(), "products", "p2"), product({ lowStockLevel: -1 }))
    );
    await assertFails(
      setDoc(
        doc(admin(), "products", "p2"),
        product({ imageUrls: ["1", "2", "3", "4", "5", "6"] })
      )
    );
  });

  test("products and categories are never deleted", async () => {
    await assertFails(deleteDoc(doc(admin(), "products", "p1")));
    await assertFails(deleteDoc(doc(admin(), "categories", "produce")));
  });

  test("the admin can add a category", async () => {
    await assertSucceeds(
      setDoc(doc(admin(), "categories", "drinks"), {
        name: "Drinks",
        sortOrder: 4,
      })
    );
    await assertFails(
      setDoc(doc(admin(), "categories", "bad"), { name: "", sortOrder: 4 })
    );
    await assertFails(
      setDoc(doc(admin(), "categories", "bad"), { name: "X", extra: true })
    );
  });

  test("the admin can set price, stock and visibility at a branch", async () => {
    const ref = doc(admin(), "branches", "ss15", "inventory", "p1");
    await assertSucceeds(setDoc(ref, { price: 4.2, stock: 7, isHidden: true }));
    await assertSucceeds(updateDoc(ref, { stock: 0 }));
  });

  test("inventory rejects bad prices, stock and extra fields", async () => {
    const ref = doc(admin(), "branches", "ss15", "inventory", "p9");
    await assertFails(setDoc(ref, { price: -1, stock: 1, isHidden: false }));
    await assertFails(setDoc(ref, { price: 1, stock: -1, isHidden: false }));
    await assertFails(setDoc(ref, { price: 1, stock: 1.5, isHidden: false }));
    await assertFails(setDoc(ref, { price: 1, stock: 1 }));
    await assertFails(
      setDoc(ref, { price: 1, stock: 1, isHidden: false, extra: 1 })
    );
    await assertFails(deleteDoc(doc(admin(), "branches", "ss15", "inventory", "p1")));
  });
});
