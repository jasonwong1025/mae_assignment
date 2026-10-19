import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { deleteObject, getBytes, ref, uploadBytes } from "firebase/storage";
import { doc, setDoc } from "firebase/firestore";
import {
  seed,
  storageForGuest,
  storageForUser,
} from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };
const WORKER = { uid: "worker", email: "worker@example.com" };
const PACKER = { uid: "packer", email: "packer@example.com" };

const photo = () => new Uint8Array([1, 2, 3, 4]);
const jpeg = { contentType: "image/jpeg" };

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  // The storage rules read the caller's role from Firestore.
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(doc(db, "users", WORKER.uid), {
      role: "storeWorker",
      workerRole: "deliveryDriver",
    });
    await setDoc(doc(db, "users", PACKER.uid), {
      role: "storeWorker",
      workerRole: "packingStaff",
      branchId: "ss15",
    });
    await setDoc(doc(db, "orders", "o1"), { driverId: WORKER.uid });
    await setDoc(doc(db, "orders", "o2"), { driverId: "someone-else" });
  });
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(
      ref(context.storage(), "products/p1/existing.jpg"),
      photo(),
      jpeg
    );
  });
});

const admin = () => storageForUser(testEnv, ADMIN.uid, ADMIN.email);

describe("product photos", () => {
  test("the admin can upload and remove a photo", async () => {
    const file = ref(admin(), "products/p1/new.jpg");
    await assertSucceeds(uploadBytes(file, photo(), jpeg));
    await assertSucceeds(deleteObject(file));
  });

  test("any signed-in user can read a photo", async () => {
    const alice = storageForUser(testEnv, ALICE.uid, ALICE.email);
    await assertSucceeds(
      getBytes(ref(alice, "products/p1/existing.jpg"))
    );
  });

  test("a guest cannot read a photo", async () => {
    await assertFails(
      getBytes(ref(storageForGuest(testEnv), "products/p1/existing.jpg"))
    );
  });

  test("customers and workers cannot upload or delete", async () => {
    for (const user of [ALICE, WORKER]) {
      const storage = storageForUser(testEnv, user.uid, user.email);
      await assertFails(
        uploadBytes(ref(storage, "products/p1/evil.jpg"), photo(), jpeg)
      );
      await assertFails(deleteObject(ref(storage, "products/p1/existing.jpg")));
    }
  });

  test("a guest cannot upload", async () => {
    await assertFails(
      uploadBytes(
        ref(storageForGuest(testEnv), "products/p1/evil.jpg"),
        photo(),
        jpeg
      )
    );
  });

  test("only images are accepted", async () => {
    await assertFails(
      uploadBytes(ref(admin(), "products/p1/script.js"), photo(), {
        contentType: "text/javascript",
      })
    );
  });

  test("photos over 5 MB are refused", async () => {
    const big = new Uint8Array(5 * 1024 * 1024 + 1);
    await assertFails(
      uploadBytes(ref(admin(), "products/p1/big.jpg"), big, jpeg)
    );
  });

  test("nothing outside products/ can be written", async () => {
    await assertFails(
      uploadBytes(ref(admin(), "other/file.jpg"), photo(), jpeg)
    );
  });
});

describe("delivery proof photos", () => {
  const worker = () => storageForUser(testEnv, WORKER.uid, WORKER.email);

  test("the assigned driver can upload the proof photo", async () => {
    await assertSucceeds(
      uploadBytes(ref(worker(), "orders/o1/proof.jpg"), photo(), jpeg)
    );
  });

  test("another driver's order is refused", async () => {
    await assertFails(
      uploadBytes(ref(worker(), "orders/o2/proof.jpg"), photo(), jpeg)
    );
  });

  test("only proof.jpg, and only an image", async () => {
    await assertFails(
      uploadBytes(ref(worker(), "orders/o1/other.jpg"), photo(), jpeg)
    );
    await assertFails(
      uploadBytes(ref(worker(), "orders/o1/proof.jpg"), photo(), {
        contentType: "text/plain",
      })
    );
  });

  test("a packer, or a deactivated driver, cannot upload", async () => {
    const packer = storageForUser(testEnv, PACKER.uid, PACKER.email);
    await assertFails(
      uploadBytes(ref(packer, "orders/o1/proof.jpg"), photo(), jpeg)
    );
    await seed(testEnv, async (db) => {
      await setDoc(doc(db, "users", WORKER.uid), {
        role: "storeWorker",
        workerRole: "deliveryDriver",
        isActive: false,
      });
    });
    await assertFails(
      uploadBytes(ref(worker(), "orders/o1/proof.jpg"), photo(), jpeg)
    );
  });

  test("the admin and the order's driver read it; others cannot", async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await uploadBytes(
        ref(context.storage(), "orders/o1/proof.jpg"),
        photo(),
        jpeg
      );
    });
    await assertSucceeds(getBytes(ref(worker(), "orders/o1/proof.jpg")));
    await assertSucceeds(getBytes(ref(admin(), "orders/o1/proof.jpg")));

    const alice = storageForUser(testEnv, ALICE.uid, ALICE.email);
    await assertFails(getBytes(ref(alice, "orders/o1/proof.jpg")));
    const packer = storageForUser(testEnv, PACKER.uid, PACKER.email);
    await assertFails(getBytes(ref(packer, "orders/o1/proof.jpg")));
    await assertFails(uploadBytes(ref(alice, "orders/o1/proof.jpg"), photo(), jpeg));
    await assertFails(uploadBytes(ref(admin(), "orders/o1/proof.jpg"), photo(), jpeg));
    await assertFails(
      getBytes(ref(storageForGuest(testEnv), "orders/o1/proof.jpg"))
    );
  });
});
