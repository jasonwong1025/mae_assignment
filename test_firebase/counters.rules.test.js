import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "counters", "orders"), { value: 1000 });
  });
});

describe("order-number counter", () => {
  // The counter does not exist on a fresh project; the first checkout
  // creates it. This is a create (resource == null), not an update.
  test("a signed-in user can create the counter the first time", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      setDoc(doc(db, "counters", "brand-new"), { value: 1001 })
    );
  });

  test("a signed-in user can read the counter", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(doc(db, "counters", "orders")));
  });

  test("the first value must be 1001", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "counters", "brand-new"), { value: 5000 })
    );
  });

  test("the counter moves forward one at a time, not in jumps", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 1002 })
    );
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 999999 })
    );
  });

  test("a signed-in user can move the counter forward", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      setDoc(doc(db, "counters", "orders"), { value: 1001 })
    );
  });

  test("the counter cannot move backward or stay the same", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 999 })
    );
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 1000 })
    );
  });

  test("extra fields are rejected", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 1001, tampered: true })
    );
  });

  test("a guest cannot read or write the counter", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(doc(db, "counters", "orders")));
    await assertFails(
      setDoc(doc(db, "counters", "orders"), { value: 1001 })
    );
  });
});
