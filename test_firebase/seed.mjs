// Seeds the catalogue (branches, categories, products, per-branch
// inventory) with sample data matching the Fresha wireframe, so the
// customer app has something to show during development.
//
// Uses the Firebase Admin SDK, which bypasses Security Rules, so it can
// write the catalogue even though client writes are denied. Authenticates
// with your gcloud Application Default Credentials.
//
// Target the real shared project (what a physical device on `flutter run`
// without a flag uses):
//   node seed.mjs
//
// If creating the worker logins fails with "Project ... has been deleted",
// your gcloud login points at an old quota project. Run it once with
//   GOOGLE_CLOUD_QUOTA_PROJECT=mae-assignment-grocerly node seed.mjs
//
// Target the local emulator instead:
//   FIRESTORE_EMULATOR_HOST=localhost:8085 node seed.mjs
//
// Re-running is safe: it overwrites the same document ids.
//
// What it writes (nothing in the apps is hardcoded any more):
//   catalogue    branches, categories, products, inventory
//   staff        Store Worker logins + profiles + driver positions
//   orders       orders in every state (Orders board, Dispatch, worker app)
//   history      ~35 days of completed orders and reviews (Sales, Reviews)
//
// Store Worker logins (all use password Worker123!):
//   packers   daniel.lee@grocerly.my (SS15), hakim.roslan@grocerly.my (SS15),
//             bryan.ong@grocerly.my (SS15), hafiz.zainal@grocerly.my
//             (Bukit Jalil), syafiq.azman@grocerly.my (Puchong)
//   drivers   amir.hamzah@grocerly.my, firdaus.rahim@grocerly.my,
//             lau.weijie@grocerly.my, weijie.tan@grocerly.my,
//             kumar.selvam@grocerly.my, azlan.shah@grocerly.my,
//             jason.tan@grocerly.my, marcus.ho@grocerly.my
//   inactive  nadia.yusof@grocerly.my, ridzuan.ali@grocerly.my (cannot sign in)
// Options:
//   --catalogue-only  only the catalogue (no staff, orders or history)
//   --with-customer   emulator only: also the E2E customer and admin

import { cert, initializeApp, applicationDefault } from "firebase-admin/app";
import {
  getFirestore,
  GeoPoint,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { readFileSync } from "node:fs";
import { buildHistory } from "./seed-data/history.mjs";

const PROJECT_ID = "mae-assignment-grocerly";

// The emulators accept any caller, so no credentials are needed there. This
// keeps the seed working in CI and on machines without gcloud set up. The
// real project still uses Application Default Credentials.
const ON_EMULATOR = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
const app = initializeApp(
  ON_EMULATOR
    ? { projectId: PROJECT_ID }
    : { credential: applicationDefault(), projectId: PROJECT_ID },
);
const db = getFirestore(app);

// `--with-customer` also creates a test customer (auth account + profile +
// one saved address) for the Patrol end-to-end journey. Only meant for the
// emulator, never the real shared project.
const WITH_CUSTOMER = process.argv.includes("--with-customer");
// `--catalogue-only` skips the staff, orders, reviews and history below.
const SKIP_DEMO = process.argv.includes("--catalogue-only");
const E2E_CUSTOMER = {
  uid: "e2e-customer",
  email: "e2e.customer@grocerly.test",
  password: "Password123!",
  name: "E2E Customer",
  phone: "0123456789",
};

/** Opening hours (minutes after midnight) for every day, same each day. */
function everyDay(opensAt, closesAt) {
  return Array.from({ length: 7 }, () => ({
    opensAt,
    closesAt,
    isClosed: false,
  }));
}

const branches = [
  {
    id: "ss15",
    name: "SS15 Subang",
    address: "12, Jalan SS15/4D, 47500 Subang Jaya, Selangor",
    phone: "03-5611 2201",
    location: new GeoPoint(3.0757, 101.5869),
    weeklyHours: everyDay(8 * 60, 21 * 60),
    maxDeliveryKm: 8,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
    isTemporarilyClosed: false,
  },
  {
    id: "bukit-jalil",
    name: "Bukit Jalil",
    address: "3, Jalan Jalil Perkasa 1, 57000 Bukit Jalil, Kuala Lumpur",
    phone: "03-8996 4410",
    location: new GeoPoint(3.0584, 101.689),
    weeklyHours: everyDay(9 * 60, 22 * 60),
    maxDeliveryKm: 10,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
    isTemporarilyClosed: false,
  },
];

const categories = [
  { id: "produce", name: "Fresh produce", sortOrder: 0 },
  { id: "dairy", name: "Dairy & eggs", sortOrder: 1 },
  { id: "bakery", name: "Bakery", sortOrder: 2 },
  { id: "pantry", name: "Pantry", sortOrder: 3 },
];

// Catalogue products. Price and stock below are per branch (see inventory).
const products = [
  { id: "p-milk", name: "Fresh milk 1L", brand: "Farm Gold", categoryId: "dairy", packSize: "1L" },
  { id: "p-chicken", name: "Chicken breast", brand: "Ayam Segar", categoryId: "produce", packSize: "1kg" },
  { id: "p-rice", name: "Basmati rice 5kg", brand: "Taj", categoryId: "pantry", packSize: "5kg" },
  { id: "p-tomato", name: "Roma tomato", brand: "Cameron Fresh", categoryId: "produce", packSize: "1kg" },
  { id: "p-pepper", name: "Yellow bell pepper", brand: "Cameron Fresh", categoryId: "produce", packSize: "each" },
  { id: "p-carrot", name: "Carrot", brand: "Cameron Fresh", categoryId: "produce", packSize: "1kg" },
  { id: "p-apple", name: "Granny Smith apple", brand: "Orchard", categoryId: "produce", packSize: "4 pack" },
  { id: "p-eggs", name: "Grade A eggs", brand: "Farm Gold", categoryId: "dairy", packSize: "10 pack" },
  { id: "p-bread", name: "Wholemeal bread", brand: "Gardenia", categoryId: "bakery", packSize: "400g" },
  { id: "p-oil", name: "Cooking oil 2L", brand: "Buruh", categoryId: "pantry", packSize: "2L" },
];

// Per-branch inventory: productId -> { price, stock, isHidden }. A couple
// are low or out of stock so "Going fast" and the out-of-stock state show.
const inventory = {
  ss15: {
    "p-milk": { price: 8.9, stock: 40 },
    "p-chicken": { price: 12.5, stock: 9 },
    "p-rice": { price: 32.0, stock: 15 },
    "p-tomato": { price: 6.8, stock: 25 },
    "p-pepper": { price: 2.5, stock: 6 },
    "p-carrot": { price: 4.2, stock: 30 },
    "p-apple": { price: 9.9, stock: 0 },
    "p-eggs": { price: 11.0, stock: 20 },
    "p-bread": { price: 3.5, stock: 18 },
    "p-oil": { price: 24.9, stock: 12 },
  },
  "bukit-jalil": {
    "p-milk": { price: 9.1, stock: 22 },
    "p-chicken": { price: 12.9, stock: 14 },
    "p-tomato": { price: 7.0, stock: 10 },
    "p-apple": { price: 10.5, stock: 8 },
    "p-bread": { price: 3.6, stock: 25 },
  },
};

/** Creates the E2E test customer: auth account, profile, one address. */
async function seedTestCustomer() {
  const onEmulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
  if (!onEmulator) {
    // Refuse to create the throwaway test account on the real project.
    throw new Error("--with-customer is only allowed against the emulator.");
  }

  const auth = getAuth(app);
  try {
    await auth.createUser({
      uid: E2E_CUSTOMER.uid,
      email: E2E_CUSTOMER.email,
      password: E2E_CUSTOMER.password,
      displayName: E2E_CUSTOMER.name,
    });
  } catch (error) {
    // Re-running the seed is fine; the account may already exist.
    if (error.code !== "auth/uid-already-exists" &&
        error.code !== "auth/email-already-exists") {
      throw error;
    }
  }

  await db.collection("users").doc(E2E_CUSTOMER.uid).set({
    name: E2E_CUSTOMER.name,
    email: E2E_CUSTOMER.email,
    phone: E2E_CUSTOMER.phone,
    role: "customer",
    createdAt: FieldValue.serverTimestamp(),
  });

  // One default address so checkout has somewhere to deliver. It sits
  // between the two seeded branches (~6 km from each), inside both
  // delivery radii (SS15 8 km, Bukit Jalil 10 km), so checkout succeeds
  // whichever branch the app selects.
  await db
    .collection("users")
    .doc(E2E_CUSTOMER.uid)
    .collection("addresses")
    .doc("home")
    .set({
      label: "Home",
      line: "Taman OUG, 58200 Kuala Lumpur",
      location: new GeoPoint(3.067, 101.638),
      note: "",
      isDefault: true,
      createdAt: FieldValue.serverTimestamp(),
    });

  // Start every run with an empty cart. The app saves carts, so a run that
  // stopped midway would otherwise leave items for the next one.
  await db
    .collection("users")
    .doc(E2E_CUSTOMER.uid)
    .collection("cart")
    .doc("current")
    .delete();

  // Orders are paid from the wallet, so start with money in it and a clean
  // history and inbox (the Functions write both while the journeys run).
  const customerDoc = db.collection("users").doc(E2E_CUSTOMER.uid);
  await customerDoc.collection("wallet").doc("current").set({
    balance: 500,
    updatedAt: FieldValue.serverTimestamp(),
  });
  for (const name of ["walletTransactions", "notifications"]) {
    for (const doc of (await customerDoc.collection(name).get()).docs) {
      await doc.ref.delete();
    }
  }
  await seedShortageOrder();
  console.log(
    `Test customer ready: ${E2E_CUSTOMER.email} / ${E2E_CUSTOMER.password}`
  );
}

/**
 * An order of the E2E customer that Daniel Lee is packing, for the shortage
 * journey: the packer reports the tomatoes unavailable and offers a
 * replacement, the customer accepts it, and the packer carries on.
 */
async function seedShortageOrder() {
  const minutesAgo = (minutes) =>
    Timestamp.fromMillis(Date.now() - minutes * 60000);
  await db.collection("orders").doc("ord-e2e-shortage").set({
    number: 2399,
    customerId: E2E_CUSTOMER.uid,
    customerName: E2E_CUSTOMER.name,
    customerPhone: E2E_CUSTOMER.phone,
    branchId: "ss15",
    branchName: "SS15 Subang",
    branchAddress: "18, Jalan SS15/4D, 47500 Subang Jaya",
    isDelivery: false,
    items: [
      {
        lineId: "L1",
        productId: "p-tomato",
        name: "Roma tomato",
        brand: "Cameron Fresh",
        packSize: "1kg",
        quantity: 2,
        unitPrice: 6.8,
        categoryId: "produce",
        category: "Fresh produce",
      },
      {
        lineId: "L2",
        productId: "p-eggs",
        name: "Grade A eggs",
        brand: "Farm Gold",
        packSize: "10 pack",
        quantity: 1,
        unitPrice: 11.0,
        categoryId: "dairy",
        category: "Dairy & eggs",
      },
    ],
    subtotal: 24.6,
    deliveryFee: 0,
    discount: 0,
    total: 24.6,
    status: "packing",
    // Paid from the wallet at checkout, so finishing packing can settle the
    // difference when the customer accepts a replacement.
    walletPaid: 24.6,
    packerId: "packer-daniel",
    packerName: "Daniel Lee",
    packerAssignedAt: minutesAgo(8),
    packingStartedAt: minutesAgo(5),
    placedAt: minutesAgo(10),
    statusSince: minutesAgo(5),
  });
}

// ---------------------------------------------------------------------------
// Demo data for the Store Admin and Store Worker apps. It lives in
// seed-data/*.json (hand-written people and orders) and seed-data/history.mjs
// (a repeatable history of completed orders and reviews), so the apps contain
// no sample data of their own.
// ---------------------------------------------------------------------------

/** Password of every seeded Store Worker account (demo accounts only). */
const WORKER_PASSWORD = "Worker123!";

/** The seed's "now". Seed files store times as minutes from this moment. */
const NOW = new Date();

/** Admin account for end-to-end tests, created only with --with-customer. */
const E2E_ADMIN = {
  uid: "e2e-admin",
  email: "e2e.admin@grocerly.test",
  password: "Password123!",
  name: "E2E Admin",
  phone: "0123456780",
};

function readJson(name) {
  return JSON.parse(readFileSync(new URL(`./seed-data/${name}`, import.meta.url), "utf8"));
}

/** Turns {$minutes} / {$geo} markers in seed files into Firestore values. */
function resolve(value) {
  if (Array.isArray(value)) return value.map(resolve);
  if (value && typeof value === "object") {
    if ("$minutes" in value) {
      return Timestamp.fromMillis(NOW.getTime() + value.$minutes * 60000);
    }
    if ("$geo" in value) return new GeoPoint(value.$geo[0], value.$geo[1]);
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, resolve(v)]));
  }
  return value;
}

/** True when Auth can be reached: the real project, or the Auth emulator. */
function canUseAuth() {
  return !ON_EMULATOR || Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST);
}

/** Creates the account, or resets its password if it already exists. */
async function ensureAccount({ uid, email, password, name }) {
  const auth = getAuth(app);
  try {
    await auth.createUser({ uid, email, password, displayName: name });
  } catch (error) {
    if (error.code !== "auth/uid-already-exists" &&
        error.code !== "auth/email-already-exists") {
      throw error;
    }
    await auth.updateUser(uid, { email, password, displayName: name });
  }
}

/** Adds branches that other demo data needs, without touching existing ones. */
async function seedExtraBranches() {
  const { branches } = readJson("staff.json");
  for (const branch of branches) {
    const ref = db.collection("branches").doc(branch.id);
    if ((await ref.get()).exists) continue;
    await ref.set({
      name: branch.name,
      address: branch.address,
      phone: branch.phone,
      location: new GeoPoint(branch.location[0], branch.location[1]),
      weeklyHours: everyDay(branch.hours.opensAt, branch.hours.closesAt),
      maxDeliveryKm: branch.maxDeliveryKm,
      baseDeliveryFee: branch.baseDeliveryFee,
      feePerKm: branch.feePerKm,
      isTemporarilyClosed: false,
      createdAt: FieldValue.serverTimestamp(),
    });
    console.log(`Added branch ${branch.name}`);
  }
}

/** Store Workers: login, users/{uid} profile, and a driver's position. */
async function seedStaff() {
  const { workers } = readJson("staff.json");
  const withAuth = canUseAuth();
  if (!withAuth) {
    console.log("No Auth emulator: skipping worker logins (profiles are still written).");
  }
  for (const worker of workers) {
    if (withAuth) {
      await ensureAccount({
        uid: worker.uid,
        email: worker.email,
        password: WORKER_PASSWORD,
        name: worker.name,
      });
    }
    await db.collection("users").doc(worker.uid).set({
      name: worker.name,
      email: worker.email,
      phone: worker.phone,
      role: "storeWorker",
      workerRole: worker.role,
      branchId: worker.branchId ?? null,
      isActive: worker.isActive,
      joinedAt: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    });
    if (worker.location && worker.isActive) {
      await db.collection("driverLocations").doc(worker.uid).set({
        position: new GeoPoint(worker.location[0], worker.location[1]),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
  console.log(`Staff: ${workers.length} workers (password for all: ${WORKER_PASSWORD}).`);
}

/** Writes documents in bulk, overwriting the same ids on a re-run. */
async function writeAll(collection, documents) {
  const writer = db.bulkWriter();
  for (const { id, data } of documents) {
    writer.set(db.collection(collection).doc(id), resolve(data));
  }
  await writer.close();
}

/** Orders in every state, for the Orders board, Dispatch and the worker app. */
async function seedOrders() {
  const orders = readJson("orders.json");
  await writeAll("orders", orders);
  console.log(`Orders: ${orders.length} in progress or recently finished.`);
}

/** Completed orders and reviews for Sales, Reviews and the dashboard. */
async function seedHistory() {
  const { workers, branches: extraBranches } = readJson("staff.json");
  const allBranches = [...branches, ...extraBranches.map((b) => ({ ...b, location: b.location }))];
  const { orders, reviews } = buildHistory({
    now: NOW,
    products,
    categories,
    inventory,
    drivers: workers
      .filter((w) => w.role === "deliveryDriver" && w.isActive)
      .map((w) => ({ id: w.uid, name: w.name })),
    branches: allBranches.map((b) => ({
      id: b.id,
      name: b.name,
      location: Array.isArray(b.location) ? b.location : [b.location.latitude, b.location.longitude],
    })),
  });
  await writeAll("orders", orders);
  await writeAll("reviews", reviews);
  console.log(`History: ${orders.length} completed orders, ${reviews.length} reviews.`);
}

/** Admin account for the Patrol end-to-end journey. Emulator only. */
async function seedTestAdmin() {
  await ensureAccount(E2E_ADMIN);
  await db.collection("users").doc(E2E_ADMIN.uid).set({
    name: E2E_ADMIN.name,
    email: E2E_ADMIN.email,
    phone: E2E_ADMIN.phone,
    role: "storeAdmin",
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log(`Test admin ready: ${E2E_ADMIN.email} / ${E2E_ADMIN.password}`);
}

async function seed() {
  const target = process.env.FIRESTORE_EMULATOR_HOST
    ? `emulator (${process.env.FIRESTORE_EMULATOR_HOST})`
    : `real project (${PROJECT_ID})`;
  console.log(`Seeding ${target}...`);
  const batch = db.batch();
  for (const { id, ...data } of branches) {
    batch.set(db.collection("branches").doc(id), {
      ...data,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  for (const { id, ...data } of categories) {
    batch.set(db.collection("categories").doc(id), data);
  }
  for (const { id, ...data } of products) {
    batch.set(db.collection("products").doc(id), { ...data, imageUrls: [] });
  }
  for (const [branchId, items] of Object.entries(inventory)) {
    for (const [productId, item] of Object.entries(items)) {
      batch.set(
        db
          .collection("branches")
          .doc(branchId)
          .collection("inventory")
          .doc(productId),
        { isHidden: false, ...item }
      );
    }
  }
  await batch.commit();
  console.log(
    `Done: ${branches.length} branches, ${categories.length} categories, ` +
      `${products.length} products, inventory for ${Object.keys(inventory).length} branches.`
  );

  if (!SKIP_DEMO) {
    await seedExtraBranches();
    await seedStaff();
    await seedOrders();
    await seedHistory();
  }
  if (WITH_CUSTOMER) {
    await seedTestCustomer();
    await seedTestAdmin();
  }
  process.exit(0);
}

seed().catch((error) => {
  console.error("Seed failed:", error);
  process.exit(1);
});
