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
// Target the local emulator instead:
//   FIRESTORE_EMULATOR_HOST=localhost:8085 node seed.mjs
//
// Re-running is safe: it overwrites the same document ids. This is a
// development convenience; the team's canonical seed will replace it.

import { cert, initializeApp, applicationDefault } from "firebase-admin/app";
import {
  getFirestore,
  GeoPoint,
  FieldValue,
} from "firebase-admin/firestore";

const PROJECT_ID = "mae-assignment-grocerly";

const app = initializeApp({
  credential: applicationDefault(),
  projectId: PROJECT_ID,
});
const db = getFirestore(app);

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
  process.exit(0);
}

seed().catch((error) => {
  console.error("Seed failed:", error);
  process.exit(1);
});
