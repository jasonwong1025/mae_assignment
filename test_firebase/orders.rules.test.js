import { beforeEach, describe, test } from "vitest";
import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  GeoPoint,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";
import { firestoreForUser, firestoreForGuest, seed } from "./helpers.js";

const ALICE = { uid: "alice", email: "alice@example.com" };
const BOB = { uid: "bob", email: "bob@example.com" };
const ADMIN = { uid: "admin", email: "admin@example.com" };
// Packing Staff at SS15, who the pending/packing orders are assigned to.
const PACKER = { uid: "packer", email: "packer@example.com" };
// Another packer at SS15, to whom nothing is assigned.
const PACKER2 = { uid: "packer2", email: "packer2@example.com" };
// A packer at another branch.
const PACKER_BJ = { uid: "packer-bj", email: "packer-bj@example.com" };
// A packer whose account HQ deactivated.
const PACKER_OFF = { uid: "packer-off", email: "packer-off@example.com" };
const DRIVER = { uid: "driver", email: "driver@example.com" };
const DRIVER2 = { uid: "driver2", email: "driver2@example.com" };

// A valid order payload owned by `customerId`, with server-set times.
function orderFor(customerId, overrides = {}) {
  return {
    number: 2301,
    customerId,
    customerName: "Aisha",
    branchId: "ss15",
    isDelivery: true,
    items: [{ productId: "p1", quantity: 1, unitPrice: 8.9 }],
    subtotal: 8.9,
    deliveryFee: 3,
    discount: 0,
    total: 11.9,
    status: "pending",
    placedAt: serverTimestamp(),
    statusSince: serverTimestamp(),
    ...overrides,
  };
}

// Stored orders (written with rules off), so each test starts from a known
// state. Two lines each, so "all packed" is two ticked lines.
const lines = [
  { lineId: "L1", productId: "p1", quantity: 1, unitPrice: 5 },
  { lineId: "L2", productId: "p2", quantity: 1, unitPrice: 5 },
];
function stored(overrides) {
  return {
    number: 1,
    customerId: ALICE.uid,
    customerName: "Aisha",
    branchId: "ss15",
    isDelivery: false,
    items: lines,
    subtotal: 10,
    deliveryFee: 0,
    discount: 0,
    total: 10,
    status: "pending",
    placedAt: new Date(),
    statusSince: new Date(),
    ...overrides,
  };
}

let testEnv;

beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ALICE.uid), { role: "customer" });
    await setDoc(doc(db, "users", BOB.uid), { role: "customer" });
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    const packer = (branchId, extra = {}) => ({
      role: "storeWorker",
      workerRole: "packingStaff",
      branchId,
      isActive: true,
      ...extra,
    });
    await setDoc(doc(db, "users", PACKER.uid), packer("ss15"));
    await setDoc(doc(db, "users", PACKER2.uid), packer("ss15"));
    await setDoc(doc(db, "users", PACKER_BJ.uid), packer("bukit-jalil"));
    await setDoc(
      doc(db, "users", PACKER_OFF.uid),
      packer("ss15", { isActive: false })
    );
    for (const driver of [DRIVER, DRIVER2]) {
      await setDoc(doc(db, "users", driver.uid), {
        role: "storeWorker",
        workerRole: "deliveryDriver",
        branchId: null,
        isActive: true,
      });
    }

    const assigned = { packerId: PACKER.uid, packerName: "Packer" };
    const driven = { ...assigned, driverId: DRIVER.uid, driverName: "Driver" };
    await setDoc(doc(db, "orders", "o-new"), stored({ isDelivery: true }));
    await setDoc(doc(db, "orders", "o-pending"), stored(assigned));
    await setDoc(
      doc(db, "orders", "o-packing"),
      stored({ ...assigned, status: "packing", packedLineIds: ["L1"] })
    );
    await setDoc(
      doc(db, "orders", "o-packed"),
      stored({ ...assigned, status: "packing", packedLineIds: ["L1", "L2"] })
    );
    await setDoc(
      doc(db, "orders", "o-ready-pickup"),
      stored({ ...assigned, status: "ready", packedLineIds: ["L1", "L2"] })
    );
    await setDoc(
      doc(db, "orders", "o-ready-delivery"),
      stored({
        ...driven,
        isDelivery: true,
        status: "ready",
        packedLineIds: ["L1", "L2"],
      })
    );
    await setDoc(
      doc(db, "orders", "o-verified"),
      stored({
        ...driven,
        isDelivery: true,
        status: "ready",
        packedLineIds: ["L1", "L2"],
        collectionVerifiedBy: DRIVER.uid,
      })
    );
    await setDoc(
      doc(db, "orders", "o-road"),
      stored({
        ...driven,
        isDelivery: true,
        status: "outForDelivery",
        collectionVerifiedBy: DRIVER.uid,
      })
    );
    await setDoc(
      doc(db, "orders", "o-done"),
      stored({ ...driven, isDelivery: true, status: "completed" })
    );
    await setDoc(
      doc(db, "orders", "o-bj"),
      stored({
        branchId: "bukit-jalil",
        packerId: PACKER_BJ.uid,
        packerName: "Packer BJ",
      })
    );
  });
});

const as = (user) => firestoreForUser(testEnv, user.uid, user.email);
const order = (db, id) => doc(db, "orders", id);

describe("placing orders", () => {
  test("clients cannot create orders, even with honest totals", async () => {
    for (const actor of [ALICE, ADMIN, PACKER, DRIVER]) {
      await assertFails(setDoc(order(as(actor), `o-${actor.uid}`), orderFor(ALICE.uid)));
    }
    await assertFails(setDoc(
      order(firestoreForGuest(testEnv), "o-guest"), orderFor(ALICE.uid)
    ));
  });
});

describe("reading orders", () => {
  test("the owner can read their own order", async () => {
    await assertSucceeds(getDoc(order(as(ALICE), "o-pending")));
  });

  test("another customer cannot read someone else's order", async () => {
    await assertFails(getDoc(order(as(BOB), "o-pending")));
  });

  test("the admin can read any order", async () => {
    await assertSucceeds(getDoc(order(as(ADMIN), "o-pending")));
    await assertSucceeds(getDoc(order(as(ADMIN), "o-bj")));
  });

  test("a packer reads their own branch's orders, not another branch's", async () => {
    await assertSucceeds(getDoc(order(as(PACKER), "o-pending")));
    // Even one not assigned to them: they find pickups and bags for drivers.
    await assertSucceeds(getDoc(order(as(PACKER2), "o-pending")));
    await assertFails(getDoc(order(as(PACKER), "o-bj")));
    await assertFails(getDoc(order(as(PACKER_BJ), "o-pending")));
  });

  test("a packer can list their branch's orders, but not all orders", async () => {
    const db = as(PACKER);
    await assertSucceeds(
      getDocs(query(collection(db, "orders"), where("branchId", "==", "ss15")))
    );
    await assertFails(getDocs(collection(db, "orders")));
    await assertFails(
      getDocs(
        query(collection(db, "orders"), where("branchId", "==", "bukit-jalil"))
      )
    );
  });

  test("a driver reads only deliveries assigned to them", async () => {
    await assertSucceeds(getDoc(order(as(DRIVER), "o-ready-delivery")));
    await assertSucceeds(getDoc(order(as(DRIVER), "o-road")));
    await assertFails(getDoc(order(as(DRIVER2), "o-ready-delivery")));
    await assertFails(getDoc(order(as(DRIVER), "o-pending")));
    await assertFails(getDoc(order(as(DRIVER), "o-bj")));
  });

  test("a driver can list their own deliveries, not all orders", async () => {
    const db = as(DRIVER);
    await assertSucceeds(
      getDocs(
        query(collection(db, "orders"), where("driverId", "==", DRIVER.uid))
      )
    );
    await assertFails(getDocs(collection(db, "orders")));
    await assertFails(
      getDocs(
        query(collection(db, "orders"), where("driverId", "==", DRIVER2.uid))
      )
    );
  });

  test("a deactivated worker cannot read orders", async () => {
    await assertFails(getDoc(order(as(PACKER_OFF), "o-pending")));
  });

  test("a guest cannot read orders", async () => {
    await assertFails(getDoc(order(firestoreForGuest(testEnv), "o-pending")));
  });
});

describe("packing", () => {
  test("the assigned packer starts packing", async () => {
    await assertSucceeds(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "packing",
        statusSince: serverTimestamp(),
        packingStartedAt: serverTimestamp(),
      })
    );
  });

  test("another packer, another branch or a deactivated packer cannot", async () => {
    const start = {
      status: "packing",
      statusSince: serverTimestamp(),
      packingStartedAt: serverTimestamp(),
    };
    await assertFails(updateDoc(order(as(PACKER2), "o-pending"), start));
    await assertFails(updateDoc(order(as(PACKER_BJ), "o-pending"), start));
    await assertFails(updateDoc(order(as(PACKER_OFF), "o-pending"), start));
    await assertFails(updateDoc(order(as(DRIVER), "o-pending"), start));
  });

  test("starting needs server times, not the phone clock", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "packing",
        statusSince: serverTimestamp(),
        packingStartedAt: new Date(2020, 0, 1),
      })
    );
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "packing",
        statusSince: new Date(),
        packingStartedAt: serverTimestamp(),
      })
    );
  });

  test("an order cannot skip packing", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "ready",
        statusSince: serverTimestamp(),
        readyAt: serverTimestamp(),
        readyBy: PACKER.uid,
      })
    );
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "completed",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("the assigned packer ticks lines while packing", async () => {
    await assertSucceeds(
      updateDoc(order(as(PACKER), "o-packing"), {
        packedLineIds: ["L1", "L2"],
      })
    );
    await assertFails(
      updateDoc(order(as(PACKER2), "o-packing"), { packedLineIds: ["L1", "L2"] })
    );
  });

  test("lines cannot be ticked before packing starts", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), { packedLineIds: ["L1"] })
    );
  });

  test("a checklist cannot hold more lines than the order", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-packing"), {
        packedLineIds: ["L1", "L2", "L3"],
      })
    );
  });

  test("the packer marks a fully packed order ready", async () => {
    await assertSucceeds(
      updateDoc(order(as(PACKER), "o-packed"), {
        status: "ready",
        statusSince: serverTimestamp(),
        readyAt: serverTimestamp(),
        readyBy: PACKER.uid,
      })
    );
  });

  test("an order with lines still to pack cannot be marked ready", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-packing"), {
        status: "ready",
        statusSince: serverTimestamp(),
        readyAt: serverTimestamp(),
        readyBy: PACKER.uid,
      })
    );
  });

  test("ready is recorded under the packer's own id", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-packed"), {
        status: "ready",
        statusSince: serverTimestamp(),
        readyAt: serverTimestamp(),
        readyBy: PACKER2.uid,
      })
    );
  });

  test("packing cannot change checkout fields or the assignment", async () => {
    await assertFails(updateDoc(order(as(PACKER), "o-packing"), { total: 0.01 }));
    await assertFails(
      updateDoc(order(as(PACKER), "o-packing"), { packerId: PACKER2.uid })
    );
    await assertFails(
      updateDoc(order(as(PACKER), "o-packing"), { driverId: PACKER.uid })
    );
  });

  test("a worker cannot cancel or reopen an order", async () => {
    await assertFails(
      updateDoc(order(as(PACKER), "o-pending"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
    await assertFails(
      updateDoc(order(as(PACKER), "o-packing"), {
        status: "pending",
        statusSince: serverTimestamp(),
      })
    );
  });
});

describe("live delivery position", () => {
  const position = (overrides = {}) => ({
    driverPosition: new GeoPoint(3.07, 101.59),
    driverPositionAt: serverTimestamp(),
    ...overrides,
  });

  test("the assigned driver reports where they are while on the road", async () => {
    await assertSucceeds(
      updateDoc(order(as(DRIVER), "o-road"), position())
    );
  });

  test("a stationary driver can refresh the position timestamp", async () => {
    await assertSucceeds(
      updateDoc(order(as(DRIVER), "o-road"), position())
    );
    await assertSucceeds(
      updateDoc(order(as(DRIVER), "o-road"), position())
    );
  });

  test("the customer who owns the order can read the position", async () => {
    await updateDoc(order(as(DRIVER), "o-road"), position());
    await assertSucceeds(getDoc(order(as(ALICE), "o-road")));
    await assertFails(getDoc(order(as(BOB), "o-road")));
  });

  test("only the assigned driver can report it", async () => {
    await assertFails(updateDoc(order(as(DRIVER2), "o-road"), position()));
    await assertFails(updateDoc(order(as(PACKER), "o-road"), position()));
    await assertFails(updateDoc(order(as(ALICE), "o-road"), position()));
    await assertFails(updateDoc(order(as(ADMIN), "o-road"), position()));
  });

  test("only while the order is out for delivery", async () => {
    await assertFails(
      updateDoc(order(as(DRIVER), "o-verified"), position())
    );
    await assertFails(updateDoc(order(as(DRIVER), "o-done"), position()));
  });

  test("the time must be the server time, not the phone clock", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER), "o-road"),
        position({ driverPositionAt: new Date(2020, 0, 1) })
      )
    );
  });

  test("the position must be a real location", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER), "o-road"),
        position({ driverPosition: "near the shop" })
      )
    );
  });

  test("both fields go together, with nothing else", async () => {
    await assertFails(
      updateDoc(order(as(DRIVER), "o-road"), {
        driverPosition: new GeoPoint(3.07, 101.59),
      })
    );
    await assertFails(
      updateDoc(order(as(DRIVER), "o-road"), position({ total: 0.01 }))
    );
  });
});

describe("self-pickup handover", () => {
  const handover = (overrides = {}) => ({
    status: "completed",
    statusSince: serverTimestamp(),
    pickupVerification: "manual",
    pickupCompletedBy: PACKER2.uid,
    pickupCompletedByName: "Packer Two",
    completedAt: serverTimestamp(),
    ...overrides,
  });

  test("any active packer at the branch hands over a ready pickup", async () => {
    await assertSucceeds(
      updateDoc(order(as(PACKER2), "o-ready-pickup"), handover())
    );
  });

  test("a packer from another branch, or a driver, cannot", async () => {
    await assertFails(
      updateDoc(order(as(PACKER_BJ), "o-ready-pickup"), handover({ pickupCompletedBy: PACKER_BJ.uid }))
    );
    await assertFails(
      updateDoc(order(as(DRIVER), "o-ready-pickup"), handover({ pickupCompletedBy: DRIVER.uid }))
    );
  });

  test("it is recorded under the packer's own id, with a known method", async () => {
    await assertFails(
      updateDoc(
        order(as(PACKER2), "o-ready-pickup"),
        handover({ pickupCompletedBy: PACKER.uid })
      )
    );
    await assertFails(
      updateDoc(
        order(as(PACKER2), "o-ready-pickup"),
        handover({ pickupVerification: "trust-me" })
      )
    );
  });

  test("only a ready pickup order can be handed over", async () => {
    await assertFails(updateDoc(order(as(PACKER2), "o-packing"), handover()));
    // A delivery order is completed by its driver, not at the counter.
    await assertFails(
      updateDoc(order(as(PACKER2), "o-ready-delivery"), handover())
    );
  });
});

describe("delivery", () => {
  const verify = (overrides = {}) => ({
    collectionVerification: "manual",
    collectionVerifiedBy: DRIVER.uid,
    collectionVerifiedAt: serverTimestamp(),
    ...overrides,
  });
  const start = {
    status: "outForDelivery",
    statusSince: serverTimestamp(),
    outForDeliveryAt: serverTimestamp(),
  };
  const finish = (overrides = {}) => ({
    status: "completed",
    statusSince: serverTimestamp(),
    deliveredBy: DRIVER.uid,
    deliveredByName: "Driver",
    proofPhotoUrl: "https://example.com/proof.jpg",
    completedAt: serverTimestamp(),
    ...overrides,
  });

  test("the assigned driver verifies the bag", async () => {
    await assertSucceeds(
      updateDoc(order(as(DRIVER), "o-ready-delivery"), verify())
    );
  });

  test("another driver or a packer cannot verify it", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER2), "o-ready-delivery"),
        verify({ collectionVerifiedBy: DRIVER2.uid })
      )
    );
    await assertFails(
      updateDoc(order(as(PACKER), "o-ready-delivery"), verify())
    );
  });

  test("verification is recorded under the driver's own id", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER), "o-ready-delivery"),
        verify({ collectionVerifiedBy: DRIVER2.uid })
      )
    );
  });

  test("the driver starts the delivery once they have verified the bag", async () => {
    await assertSucceeds(updateDoc(order(as(DRIVER), "o-verified"), start));
  });

  test("starting without verifying first is refused", async () => {
    await assertFails(updateDoc(order(as(DRIVER), "o-ready-delivery"), start));
  });

  test("an order still being packed cannot be started or verified", async () => {
    await assertFails(updateDoc(order(as(DRIVER), "o-packing"), start));
  });

  test("the driver completes the delivery with a proof photo", async () => {
    await assertSucceeds(updateDoc(order(as(DRIVER), "o-road"), finish()));
  });

  test("completion needs a photo and the driver's own id", async () => {
    await assertFails(
      updateDoc(order(as(DRIVER), "o-road"), finish({ proofPhotoUrl: "" }))
    );
    await assertFails(
      updateDoc(order(as(DRIVER), "o-road"), finish({ deliveredBy: DRIVER2.uid }))
    );
  });

  test("another driver cannot complete someone else's delivery", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER2), "o-road"),
        finish({ deliveredBy: DRIVER2.uid })
      )
    );
  });

  test("a delivery cannot be completed before it is on the road", async () => {
    await assertFails(
      updateDoc(order(as(DRIVER), "o-verified"), finish())
    );
  });

  test("times come from the server", async () => {
    await assertFails(
      updateDoc(
        order(as(DRIVER), "o-road"),
        finish({ completedAt: new Date(2020, 0, 1) })
      )
    );
  });

  test("a deactivated driver cannot act", async () => {
    await seed(testEnv, async (db) => {
      await setDoc(doc(db, "users", DRIVER.uid), {
        role: "storeWorker",
        workerRole: "deliveryDriver",
        isActive: false,
      });
    });
    await assertFails(updateDoc(order(as(DRIVER), "o-road"), finish()));
  });
});

describe("the admin", () => {
  test("assigns a packer and a driver with server times", async () => {
    await assertSucceeds(
      updateDoc(order(as(ADMIN), "o-new"), {
        packerId: PACKER2.uid,
        packerName: "Packer Two",
        packerAssignedAt: serverTimestamp(),
        driverId: DRIVER.uid,
        driverName: "Driver",
        driverAssignedAt: serverTimestamp(),
      })
    );
  });

  test("cannot stamp an assignment with the phone clock", async () => {
    await assertFails(
      updateDoc(order(as(ADMIN), "o-new"), {
        packerId: PACKER2.uid,
        packerName: "Packer Two",
        packerAssignedAt: new Date(2020, 0, 1),
      })
    );
  });

  test("cannot change checkout fields", async () => {
    await assertFails(updateDoc(order(as(ADMIN), "o-new"), { total: 0.01 }));
    await assertFails(
      updateDoc(order(as(ADMIN), "o-new"), {
        items: [{ lineId: "L9", productId: "p9", quantity: 1 }],
      })
    );
  });

  test("cannot write the worker's fulfilment fields", async () => {
    await assertFails(
      updateDoc(order(as(ADMIN), "o-new"), { proofPhotoUrl: "https://x" })
    );
  });

  test("a deactivated admin profile loses access", async () => {
    await seed(testEnv, async (db) => {
      await setDoc(doc(db, "users", ADMIN.uid), {
        role: "storeAdmin",
        isActive: false,
      });
    });
    await assertFails(getDoc(order(as(ADMIN), "o-new")));
  });
});

describe("customers", () => {
  test("cannot change their order's status", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-pending"), { status: "completed" })
    );
  });

  test("the owner must cancel through the Function", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-pending"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("the owner cannot cancel once packing has started", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-packing"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("a cancel cannot change anything else on the order", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-pending"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
        total: 0.01,
      })
    );
  });

  test("a cancel must use the server time", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-pending"), {
        status: "cancelled",
        statusSince: new Date(0),
      })
    );
  });

  test("another customer cannot cancel someone else's order", async () => {
    await assertFails(
      updateDoc(order(as(BOB), "o-pending"), {
        status: "cancelled",
        statusSince: serverTimestamp(),
      })
    );
  });

  test("the owner cannot move their order to any other status", async () => {
    await assertFails(
      updateDoc(order(as(ALICE), "o-pending"), {
        status: "packing",
        statusSince: serverTimestamp(),
      })
    );
  });
});

describe("shortages", () => {
  const replacement = (overrides = {}) => ({
    lineId: "L2",
    productId: "p9",
    name: "Other milk",
    quantity: 1,
    unitPrice: 6,
    ...overrides,
  });
  const propose = (overrides = {}) => ({
    "shortages.L2": {
      status: "proposed",
      replacement: replacement(),
      flaggedAt: serverTimestamp(),
    },
    shortageLineId: "L2",
    openShortages: 1,
    ...overrides,
  });
  const removeLine = (overrides = {}) => ({
    "shortages.L2": { status: "removed", flaggedAt: serverTimestamp() },
    shortageLineId: "L2",
    ...overrides,
  });
  const ready = {
    status: "ready",
    statusSince: serverTimestamp(),
    readyAt: serverTimestamp(),
    readyBy: PACKER.uid,
  };
  const at = new Date(2026, 0, 1);
  const proposed = {
    status: "proposed",
    replacement: replacement(),
    flaggedAt: at,
  };
  const decide = (status, overrides = {}) => ({
    "shortages.L2": { ...proposed, status, decidedAt: serverTimestamp() },
    shortageLineId: "L2",
    openShortages: 0,
    ...overrides,
  });

  beforeEach(async () => {
    await seed(testEnv, async (db) => {
      await setDoc(
        doc(db, "orders", "o-waiting"),
        stored({
          packerId: PACKER.uid,
          packerName: "Packer",
          status: "packing",
          packedLineIds: ["L1"],
          shortages: { L2: proposed },
          openShortages: 1,
        })
      );
    });
  });

  describe("flagging", () => {
    test("the packer proposes a replacement", async () => {
      await assertSucceeds(
        updateDoc(order(as(PACKER), "o-packing"), propose())
      );
    });

    test("the packer removes a line with no replacement", async () => {
      await assertSucceeds(
        updateDoc(order(as(PACKER), "o-packing"), removeLine())
      );
    });

    test("only the assigned, active packer can flag", async () => {
      await assertFails(updateDoc(order(as(PACKER2), "o-packing"), propose()));
      await assertFails(updateDoc(order(as(PACKER_BJ), "o-packing"), propose()));
      await assertFails(updateDoc(order(as(DRIVER), "o-packing"), propose()));
      await assertFails(updateDoc(order(as(ALICE), "o-packing"), propose()));
    });

    test("only while packing", async () => {
      await assertFails(updateDoc(order(as(PACKER), "o-pending"), propose()));
    });

    test("a ticked line cannot be flagged", async () => {
      await assertFails(
        updateDoc(order(as(PACKER), "o-packing"), {
          "shortages.L1": {
            status: "removed",
            flaggedAt: serverTimestamp(),
          },
          shortageLineId: "L1",
        })
      );
    });

    test("a line cannot be flagged twice", async () => {
      await assertFails(updateDoc(order(as(PACKER), "o-waiting"), removeLine()));
    });

    test("the flag time must be the server time", async () => {
      await assertFails(
        updateDoc(
          order(as(PACKER), "o-packing"),
          propose({
            "shortages.L2": { ...proposed, flaggedAt: new Date(2020, 0, 1) },
          })
        )
      );
    });

    test("a proposal must be counted as open", async () => {
      await assertFails(
        updateDoc(
          order(as(PACKER), "o-packing"),
          propose({ openShortages: 0 })
        )
      );
      await assertFails(
        updateDoc(
          order(as(PACKER), "o-packing"),
          propose({ openShortages: 5 })
        )
      );
    });

    test("a replacement must be shaped like an item for that line", async () => {
      const flag = (r) =>
        propose({
          "shortages.L2": {
            status: "proposed",
            replacement: r,
            flaggedAt: serverTimestamp(),
          },
        });
      await assertFails(
        updateDoc(
          order(as(PACKER), "o-packing"),
          flag(replacement({ lineId: "L1" }))
        )
      );
      await assertFails(
        updateDoc(
          order(as(PACKER), "o-packing"),
          flag(replacement({ quantity: "1" }))
        )
      );
    });

    test("the packer cannot accept their own proposal", async () => {
      await assertFails(
        updateDoc(order(as(PACKER), "o-waiting"), decide("accepted"))
      );
    });

    test("flagging cannot touch other fields", async () => {
      await assertFails(
        updateDoc(order(as(PACKER), "o-packing"), propose({ total: 0.01 }))
      );
    });
  });

  describe("the customer's reply", () => {
    test("accepts the replacement", async () => {
      await assertSucceeds(
        updateDoc(order(as(ALICE), "o-waiting"), decide("accepted"))
      );
    });

    test("declines it, which removes the line", async () => {
      await assertSucceeds(
        updateDoc(order(as(ALICE), "o-waiting"), decide("removed"))
      );
    });

    test("only the owner replies", async () => {
      await assertFails(
        updateDoc(order(as(BOB), "o-waiting"), decide("accepted"))
      );
    });

    test("the reply is stamped with the server time", async () => {
      await assertFails(
        updateDoc(
          order(as(ALICE), "o-waiting"),
          decide("accepted", {
            "shortages.L2": {
              ...proposed,
              status: "accepted",
              decidedAt: new Date(2020, 0, 1),
            },
          })
        )
      );
    });

    test("the reply must close the open count", async () => {
      await assertFails(
        updateDoc(
          order(as(ALICE), "o-waiting"),
          decide("accepted", { openShortages: 1 })
        )
      );
    });

    test("cannot swap the replacement while accepting", async () => {
      await assertFails(
        updateDoc(
          order(as(ALICE), "o-waiting"),
          decide("accepted", {
            "shortages.L2": {
              ...proposed,
              replacement: replacement({ unitPrice: 0.01 }),
              status: "accepted",
              decidedAt: serverTimestamp(),
            },
          })
        )
      );
    });

    test("cannot reply to a line with no proposal", async () => {
      await assertFails(
        updateDoc(order(as(ALICE), "o-packing"), decide("accepted"))
      );
    });

    test("cannot reply twice", async () => {
      await seed(testEnv, async (db) => {
        await setDoc(
          doc(db, "orders", "o-decided"),
          stored({
            status: "packing",
            packedLineIds: ["L1"],
            shortages: { L2: { ...proposed, status: "accepted", decidedAt: at } },
            openShortages: 0,
          })
        );
      });
      await assertFails(
        updateDoc(
          order(as(ALICE), "o-decided"),
          decide("removed", { openShortages: -1 })
        )
      );
    });

    test("cannot reply once the order has moved past packing", async () => {
      await seed(testEnv, async (db) => {
        await setDoc(
          doc(db, "orders", "o-cancelled"),
          stored({
            status: "cancelled",
            shortages: { L2: proposed },
            openShortages: 1,
          })
        );
      });
      await assertFails(
        updateDoc(order(as(ALICE), "o-cancelled"), decide("accepted"))
      );
    });
  });

  describe("marking ready", () => {
    test("is blocked while a proposal is open", async () => {
      await assertFails(
        updateDoc(order(as(PACKER), "o-waiting"), {
          ...ready,
          packedLineIds: ["L1", "L2"],
        })
      );
    });

    test("works once the removed line is counted in the checklist", async () => {
      await seed(testEnv, async (db) => {
        await setDoc(
          doc(db, "orders", "o-removed"),
          stored({
            packerId: PACKER.uid,
            packerName: "Packer",
            status: "packing",
            packedLineIds: ["L1"],
            shortages: { L2: { status: "removed", flaggedAt: at } },
            openShortages: 0,
          })
        );
      });
      await assertSucceeds(
        updateDoc(order(as(PACKER), "o-removed"), {
          ...ready,
          packedLineIds: ["L1", "L2"],
        })
      );
    });
  });

  describe("the admin", () => {
    const cancel = { status: "cancelled", statusSince: serverTimestamp() };

    test("must cancel through the Function", async () => {
      await assertFails(updateDoc(order(as(ADMIN), "o-waiting"), cancel));
    });

    test("can cancel only, not set any other status", async () => {
      for (const status of ["completed", "ready", "pending", "packing"]) {
        await assertFails(
          updateDoc(order(as(ADMIN), "o-waiting"), {
            status,
            statusSince: serverTimestamp(),
          })
        );
      }
    });

    test("cannot cancel a finished order", async () => {
      await assertFails(updateDoc(order(as(ADMIN), "o-done"), cancel));
    });

    test("a cancel needs the server time and nothing else", async () => {
      await assertFails(
        updateDoc(order(as(ADMIN), "o-waiting"), {
          status: "cancelled",
          statusSince: new Date(0),
        })
      );
      await assertFails(
        updateDoc(order(as(ADMIN), "o-waiting"), { ...cancel, total: 0.01 })
      );
    });

    test("cannot answer for the customer", async () => {
      await assertFails(
        updateDoc(order(as(ADMIN), "o-waiting"), decide("accepted"))
      );
    });
  });
});

describe("deleting", () => {
  test("nobody can delete an order", async () => {
    await assertFails(deleteDoc(order(as(ADMIN), "o-pending")));
    await assertFails(deleteDoc(order(as(ALICE), "o-pending")));
  });
});
