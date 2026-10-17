import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, deleteDoc } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

function address() {
  return {
    label: "Home",
    line: "12 Jalan Besar",
    location: { latitude: 3.1, longitude: 101.6 },
    note: "",
    isDefault: true,
  };
}

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(
      doc(db, "users", ALICE.uid, "addresses", "a1"),
      address()
    );
  });
});

describe("saved addresses are private to the owner", () => {
  test("the owner can read their own addresses", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      getDoc(doc(db, "users", ALICE.uid, "addresses", "a1"))
    );
  });

  test("the owner can create, edit and delete their addresses", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      setDoc(doc(db, "users", ALICE.uid, "addresses", "a2"), address())
    );
    await assertSucceeds(
      setDoc(
        doc(db, "users", ALICE.uid, "addresses", "a2"),
        { ...address(), label: "Office" }
      )
    );
    await assertSucceeds(
      deleteDoc(doc(db, "users", ALICE.uid, "addresses", "a2"))
    );
  });

  test("another customer cannot read someone's addresses", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(
      getDoc(doc(db, "users", ALICE.uid, "addresses", "a1"))
    );
  });

  test("another customer cannot write someone's addresses", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid, "addresses", "a3"), address())
    );
  });

  test("not even the admin can read a customer's addresses", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(
      getDoc(doc(db, "users", ALICE.uid, "addresses", "a1"))
    );
  });

  test("a guest cannot read addresses", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(
      getDoc(doc(db, "users", ALICE.uid, "addresses", "a1"))
    );
  });
});
