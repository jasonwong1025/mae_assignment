import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

assert(process.env.FIRESTORE_EMULATOR_HOST);
assert(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const app = initializeApp({
  projectId: "mae-assignment-grocerly",
  storageBucket: "mae-assignment-grocerly.firebasestorage.app",
});
const db = getFirestore(app);
const bucket = getStorage(app).bucket();
const user = db.doc("users/reset-demo-test");
await user.set({ role: "customer" });
await user.collection("addresses").doc("home").set({ label: "Home" });
await user.collection("cart").doc("current").set({ items: [] });
await user.collection("wallet").doc("current").set({ balance: 42 });
await user.collection("walletTransactions").doc("one").set({ amount: 42 });
await user.collection("notifications").doc("one").set({ orderId: "one" });
await db.doc("orders/one").set({ number: 1 });
await db.doc("reviews/one").set({ orderId: "one" });
await db.doc("products/p-test").set({ imageUrls: ["keep"] });
await db.doc("products/p-rice").set({ imageUrls: ["keep"] });
await db.doc("branches/one/inventory/p-test").set({ stock: 3 });
await db.doc("branches/puchong").set({ name: "Puchong" });
await db.doc("branches/extra-puchong").set({ name: "Puchong" });
await db.doc("branches/extra-puchong/inventory/p-test").set({ stock: 2 });
await bucket.file("orders/one/proof.jpg").save(Buffer.from("proof"));
await bucket.file("products/p-test/catalogue.png").save(Buffer.from("photo"));

execFileSync(process.execPath, ["reset_demo.mjs", "--apply", "--confirm-project=mae-assignment-grocerly", "--seed-orders"], { stdio: "inherit" });

for (const path of ["orders/one", "reviews/one", "users/reset-demo-test/cart/current", "users/reset-demo-test/wallet/current", "users/reset-demo-test/walletTransactions/one", "users/reset-demo-test/notifications/one"]) {
  assert.equal((await db.doc(path).get()).exists, false, `${path} should be deleted`);
}
for (const path of ["users/reset-demo-test", "users/reset-demo-test/addresses/home", "products/p-test", "branches/one/inventory/p-test"]) {
  assert.equal((await db.doc(path).get()).exists, true, `${path} should be preserved`);
}
assert.equal((await bucket.file("orders/one/proof.jpg").exists())[0], false);
assert.equal((await bucket.file("products/p-test/catalogue.png").exists())[0], true);
assert.equal((await db.doc("branches/puchong").get()).exists, true);
assert.equal((await db.doc("branches/extra-puchong").get()).exists, false);
assert.equal((await db.doc("branches/extra-puchong/inventory/p-test").get()).exists, false);
assert.equal((await db.collection("orders").count().get()).data().count, 40);
assert((await db.doc("counters/orders").get()).get("value") >= 2311);
execFileSync(process.execPath, ["seed.mjs", "--catalogue-only"], { stdio: "inherit" });
assert.deepEqual((await db.doc("products/p-rice").get()).get("imageUrls"), ["keep"]);
console.log("Emulator reset assertions passed.");
