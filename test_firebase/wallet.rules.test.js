import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  addDoc, collection, deleteDoc, doc, getDoc, getDocs, serverTimestamp, setDoc, updateDoc,
} from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

let testEnv;
const as = (user) => firestoreForUser(testEnv, user.uid, user.email);
const wallet = (db, uid) => doc(db, "users", uid, "wallet", "current");
const entries = (db, uid) => collection(db, "users", uid, "walletTransactions");
const inbox = (db, uid, id = "n1") => doc(db, "users", uid, "notifications", id);
const device = (db, uid, token = "tok-1") => doc(db, "users", uid, "devices", token);

beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(wallet(db, ALICE.uid), { balance: 50, updatedAt: new Date() });
    await setDoc(doc(db, "users", ALICE.uid, "walletTransactions", "t1"), {
      type: "topUp", amount: 50, balanceAfter: 50, description: "Top up", createdAt: new Date(),
    });
    await setDoc(inbox(db, ALICE.uid), {
      title: "Order ready", body: "Come and get it", read: false, createdAt: new Date(),
    });
  });
});

describe("wallet", () => {
  test("the owner reads their balance and history", async () => {
    await assertSucceeds(getDoc(wallet(as(ALICE), ALICE.uid)));
    await assertSucceeds(getDocs(entries(as(ALICE), ALICE.uid)));
  });

  test("nobody else reads it, not even the admin", async () => {
    await assertFails(getDoc(wallet(as(BOB), ALICE.uid)));
    await assertFails(getDocs(entries(as(BOB), ALICE.uid)));
    await assertFails(getDoc(wallet(as(ADMIN), ALICE.uid)));
    await assertFails(getDoc(wallet(firestoreForGuest(testEnv), ALICE.uid)));
  });

  test("a client cannot change the balance, even its own", async () => {
    const db = as(ALICE);
    await assertFails(setDoc(wallet(db, ALICE.uid), { balance: 5000 }));
    await assertFails(updateDoc(wallet(db, ALICE.uid), { balance: 5000 }));
    await assertFails(deleteDoc(wallet(db, ALICE.uid)));
    await assertFails(setDoc(wallet(as(BOB), BOB.uid), { balance: 10 }));
  });

  test("a client cannot write history entries", async () => {
    const db = as(ALICE);
    await assertFails(
      addDoc(entries(db, ALICE.uid), { type: "topUp", amount: 999, createdAt: serverTimestamp() })
    );
    await assertFails(
      updateDoc(doc(db, "users", ALICE.uid, "walletTransactions", "t1"), { amount: 1 })
    );
    await assertFails(deleteDoc(doc(db, "users", ALICE.uid, "walletTransactions", "t1")));
  });
});

describe("notification inbox", () => {
  test("the owner reads, marks read and clears their notifications", async () => {
    const db = as(ALICE);
    await assertSucceeds(getDoc(inbox(db, ALICE.uid)));
    await assertSucceeds(updateDoc(inbox(db, ALICE.uid), { read: true }));
    await assertSucceeds(deleteDoc(inbox(db, ALICE.uid)));
  });

  test("only the read flag can change", async () => {
    const db = as(ALICE);
    await assertFails(updateDoc(inbox(db, ALICE.uid), { title: "Free money" }));
    await assertFails(updateDoc(inbox(db, ALICE.uid), { read: "yes" }));
  });

  test("a client cannot create notifications, for itself or others", async () => {
    await assertFails(setDoc(inbox(as(ALICE), ALICE.uid, "n2"), { title: "x", read: false }));
    await assertFails(setDoc(inbox(as(BOB), ALICE.uid, "n3"), { title: "x", read: false }));
  });

  test("another user cannot read or touch them", async () => {
    await assertFails(getDoc(inbox(as(BOB), ALICE.uid)));
    await assertFails(updateDoc(inbox(as(BOB), ALICE.uid), { read: true }));
    await assertFails(deleteDoc(inbox(as(BOB), ALICE.uid)));
  });
});

describe("push devices", () => {
  const registration = (overrides = {}) => ({
    platform: "android", updatedAt: serverTimestamp(), ...overrides,
  });

  test("the owner registers and removes their own phone", async () => {
    const db = as(ALICE);
    await assertSucceeds(setDoc(device(db, ALICE.uid), registration()));
    await assertSucceeds(setDoc(device(db, ALICE.uid), registration({ platform: "ios" })));
    await assertSucceeds(deleteDoc(device(db, ALICE.uid)));
  });

  test("nobody registers a phone for someone else", async () => {
    await assertFails(setDoc(device(as(BOB), ALICE.uid), registration()));
    await assertFails(getDoc(device(as(BOB), ALICE.uid)));
  });

  test("shape: platform, server time and nothing else", async () => {
    const db = as(ALICE);
    await assertFails(setDoc(device(db, ALICE.uid), registration({ platform: "toaster" })));
    await assertFails(setDoc(device(db, ALICE.uid), registration({ updatedAt: new Date(2020, 0, 1) })));
    await assertFails(setDoc(device(db, ALICE.uid), registration({ extra: 1 })));
    await assertFails(setDoc(device(db, ALICE.uid), { platform: "android" }));
  });

  test("a guest cannot register", async () => {
    await assertFails(setDoc(device(firestoreForGuest(testEnv), ALICE.uid), registration()));
  });
});
