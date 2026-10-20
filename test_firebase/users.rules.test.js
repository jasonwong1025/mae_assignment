import { beforeEach, describe, test } from "vitest";
import {
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
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

/** A valid customer document exactly as the Flutter app writes it. */
function customerDoc(email) {
  return {
    name: "Alice",
    email,
    phone: "0123456789",
    role: "customer",
    createdAt: serverTimestamp(),
  };
}

let testEnv;
beforeEach(() => {
  testEnv = globalThis.__TEST_ENV__;
});

describe("users/{uid} create", () => {
  test("owner can create their own customer profile", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      setDoc(doc(db, "users", ALICE.uid), customerDoc(ALICE.email))
    );
  });

  test("guest cannot create a profile", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid), customerDoc(ALICE.email))
    );
  });

  test("cannot create a profile for a different uid", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "users", BOB.uid), customerDoc(BOB.email))
    );
  });

  test("cannot self-create a store role", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid), {
        ...customerDoc(ALICE.email),
        role: "storeAdmin",
      })
    );
  });

  test("email must match the auth token", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid), customerDoc("someone-else@example.com"))
    );
  });

  test("extra fields are rejected", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid), {
        ...customerDoc(ALICE.email),
        isAdmin: true,
      })
    );
  });

  test("createdAt must be the server time", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      setDoc(doc(db, "users", ALICE.uid), {
        ...customerDoc(ALICE.email),
        createdAt: new Date("2020-01-01"),
      })
    );
  });
});

describe("staff provisioning", () => {
  const admin = { uid: "admin", email: "admin@example.com" };
  const worker = { uid: "worker", email: "worker@example.com" };

  beforeEach(async () => {
    await seed(testEnv, async (db) => {
      await setDoc(doc(db, "users", admin.uid), { role: "storeAdmin" });
      await setDoc(doc(db, "users", worker.uid), {
        role: "storeWorker", workerRole: "packingStaff",
        branchId: "ss15", email: worker.email, isActive: true,
      });
    });
  });

  test("even HQ admin cannot create a worker profile directly", async () => {
    const db = firestoreForUser(testEnv, admin.uid, admin.email);
    await assertFails(setDoc(doc(db, "users", "new-worker"), {
      role: "storeWorker", workerRole: "packingStaff",
      branchId: "ss15", email: "new@example.com", isActive: true,
    }));
  });

  test("even HQ admin cannot toggle the Auth account from Firestore", async () => {
    const db = firestoreForUser(testEnv, admin.uid, admin.email);
    await assertFails(updateDoc(doc(db, "users", worker.uid), { isActive: false }));
  });

  test("HQ admin can still edit worker details", async () => {
    const db = firestoreForUser(testEnv, admin.uid, admin.email);
    await assertSucceeds(updateDoc(doc(db, "users", worker.uid), { phone: "0120000000" }));
  });
});

describe("users/{uid} read", () => {
  beforeEach(async () => {
    await seed(testEnv, (db) =>
      setDoc(doc(db, "users", ALICE.uid), {
        name: "Alice",
        email: ALICE.email,
        phone: "0123456789",
        role: "customer",
      })
    );
  });

  test("owner can read their own profile", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(getDoc(doc(db, "users", ALICE.uid)));
  });

  test("another user cannot read someone else's profile", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(getDoc(doc(db, "users", ALICE.uid)));
  });

  test("guest cannot read a profile", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(doc(db, "users", ALICE.uid)));
  });
});

describe("users/{uid} update", () => {
  beforeEach(async () => {
    await seed(testEnv, (db) =>
      setDoc(doc(db, "users", ALICE.uid), {
        name: "Alice",
        email: ALICE.email,
        phone: "0123456789",
        role: "customer",
      })
    );
  });

  test("owner can change their name and phone", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      updateDoc(doc(db, "users", ALICE.uid), {
        name: "Alice Tan",
        phone: "0199999999",
      })
    );
  });

  test("owner cannot change their role", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "users", ALICE.uid), { role: "storeAdmin" })
    );
  });

  test("owner cannot change their email", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(
      updateDoc(doc(db, "users", ALICE.uid), { email: "new@example.com" })
    );
  });

  test("another user cannot update someone else's profile", async () => {
    const db = firestoreForUser(testEnv, BOB.uid, BOB.email);
    await assertFails(
      updateDoc(doc(db, "users", ALICE.uid), { name: "Hacked" })
    );
  });
});

describe("users/{uid} delete", () => {
  beforeEach(async () => {
    await seed(testEnv, (db) =>
      setDoc(doc(db, "users", ALICE.uid), {
        name: "Alice",
        email: ALICE.email,
        phone: "0123456789",
        role: "customer",
      })
    );
  });

  test("owner cannot delete their profile", async () => {
    const db = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(deleteDoc(doc(db, "users", ALICE.uid)));
  });
});
