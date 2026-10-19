import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  collection,
  serverTimestamp,
  setDoc,
} from "firebase/firestore";
import { GeoPoint } from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const DRIVER = { uid: "driver-1", email: "driver1@example.com" };
const OTHER_DRIVER = { uid: "driver-2", email: "driver2@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };

function position(overrides = {}) {
  return {
    position: new GeoPoint(3.07, 101.58),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

let testEnv;

beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", DRIVER.uid), { role: "storeWorker" });
    await setDoc(doc(db, "users", OTHER_DRIVER.uid), { role: "storeWorker" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(doc(db, "driverLocations", OTHER_DRIVER.uid), {
      position: new GeoPoint(3.0, 101.5),
      updatedAt: new Date(),
    });
  });
});

const driver = () => firestoreForUser(testEnv, DRIVER.uid, DRIVER.email);

describe("writing a driver location", () => {
  test("a worker records their own position", async () => {
    await assertSucceeds(
      setDoc(doc(driver(), "driverLocations", DRIVER.uid), position())
    );
  });

  test("a worker cannot record someone else's position", async () => {
    await assertFails(
      setDoc(doc(driver(), "driverLocations", OTHER_DRIVER.uid), position())
    );
  });

  test("the position must be a map location", async () => {
    await assertFails(
      setDoc(
        doc(driver(), "driverLocations", DRIVER.uid),
        position({ position: "3.07,101.58" })
      )
    );
  });

  test("updatedAt must be the server time", async () => {
    await assertFails(
      setDoc(
        doc(driver(), "driverLocations", DRIVER.uid),
        position({ updatedAt: new Date(0) })
      )
    );
  });

  test("unknown fields are rejected", async () => {
    await assertFails(
      setDoc(
        doc(driver(), "driverLocations", DRIVER.uid),
        position({ speed: 120 })
      )
    );
  });

  test("a customer, the admin and a guest cannot write", async () => {
    const alice = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    for (const db of [alice, admin, firestoreForGuest(testEnv)]) {
      await assertFails(
        setDoc(doc(db, "driverLocations", DRIVER.uid), position())
      );
    }
  });

  test("nobody deletes a location", async () => {
    await assertFails(deleteDoc(doc(driver(), "driverLocations", OTHER_DRIVER.uid)));
  });
});

describe("reading driver locations", () => {
  test("staff can read them", async () => {
    const admin = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertSucceeds(getDocs(collection(admin, "driverLocations")));
    await assertSucceeds(getDoc(doc(driver(), "driverLocations", OTHER_DRIVER.uid)));
  });

  test("a customer and a guest cannot", async () => {
    const alice = firestoreForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(getDocs(collection(alice, "driverLocations")));
    await assertFails(
      getDoc(doc(firestoreForGuest(testEnv), "driverLocations", DRIVER.uid))
    );
  });
});
