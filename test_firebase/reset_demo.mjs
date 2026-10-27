// Preview by default. Run with --apply --confirm-project=mae-assignment-grocerly
// to clear demo activity from the shared project. Add --seed-orders to restore
// the compact 40-order board without the 35-day history.
import { applicationDefault, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const projectId = "mae-assignment-grocerly";
const bucketName = `${projectId}.firebasestorage.app`;
const args = new Set(process.argv.slice(2));
const apply = args.has("--apply");
const seedOrders = args.has("--seed-orders");
const confirm = `--confirm-project=${projectId}`;
const known = new Set(["--apply", "--seed-orders", confirm]);
for (const arg of args) {
  if (!known.has(arg)) throw new Error(`Unknown option: ${arg}`);
}
if (apply && !args.has(confirm)) {
  throw new Error(`Live reset requires ${confirm}`);
}
if (seedOrders && !apply) {
  throw new Error("--seed-orders requires --apply");
}
if (process.env.GCLOUD_PROJECT && process.env.GCLOUD_PROJECT !== projectId ||
    process.env.GOOGLE_CLOUD_PROJECT && process.env.GOOGLE_CLOUD_PROJECT !== projectId) {
  throw new Error("Environment project differs from Grocerly Dev.");
}
const emulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
if (emulator && !process.env.FIREBASE_STORAGE_EMULATOR_HOST) {
  throw new Error("Set FIREBASE_STORAGE_EMULATOR_HOST too, to avoid mixing emulator Firestore and live Storage.");
}
if (!emulator && process.env.FIREBASE_STORAGE_EMULATOR_HOST) {
  throw new Error("Storage emulator is set without Firestore emulator.");
}
const app = initializeApp({
  projectId,
  storageBucket: bucketName,
  ...(emulator ? {} : { credential: applicationDefault() }),
});
const db = getFirestore(app);
const bucket = getStorage(app).bucket();
const userCollections = ["cart", "groceryList", "notifications", "walletTransactions", "wallet"];
const canonicalBranchIds = new Set(["ss15", "bukit-jalil", "puchong"]);

async function count(ref) {
  return (await ref.count().get()).data().count;
}

async function run() {
  console.log(`Target: ${emulator ? `Firestore emulator ${process.env.FIRESTORE_EMULATOR_HOST}` : "LIVE"} / ${projectId}`);
  const users = await db.collection("users").listDocuments();
  const branches = await db.collection("branches").get();
  const canonicalNames = new Set(branches.docs
    .filter((branch) => canonicalBranchIds.has(branch.id))
    .map((branch) => branch.get("name")?.trim().toLowerCase()));
  const duplicateBranches = branches.docs.filter((branch) =>
    !canonicalBranchIds.has(branch.id) &&
    typeof branch.get("name") === "string" &&
    canonicalNames.has(branch.get("name")?.trim().toLowerCase()));
  const userProfiles = await db.collection("users").get();
  for (const branch of duplicateBranches) {
    const assigned = userProfiles.docs.filter((user) => user.get("branchId") === branch.id);
    if (assigned.length) throw new Error(`Cannot remove duplicate branch ${branch.id}: ${assigned.length} account(s) still assigned to it.`);
  }
  const plan = [];
  for (const name of ["orders", "reviews"]) {
    const ref = db.collection(name);
    plan.push({ label: name, ref, count: await count(ref) });
  }
  for (const user of users) {
    for (const name of userCollections) {
      const ref = user.collection(name);
      const total = await count(ref);
      if (total) plan.push({ label: `users/${user.id}/${name}`, ref, count: total });
    }
  }
  const [proofs] = await bucket.getFiles({ prefix: "orders/" });
  for (const item of plan) console.log(`${item.label}: ${item.count} document(s)`);
  for (const branch of duplicateBranches) {
    const stock = await count(branch.ref.collection("inventory"));
    console.log(`Duplicate branch ${branch.id} (${branch.get("name")}): branch + ${stock} inventory document(s)`);
  }
  console.log(`Storage orders/: ${proofs.length} object(s)`);
  console.log(`Preserved: Auth accounts, users and addresses, canonical branches and their inventory, categories, products, driver locations, device tokens, product images, order number counter.`);
  if (!apply) {
    console.log(`DRY RUN. To clear activity: node reset_demo.mjs --apply ${confirm}`);
    console.log(`Add --seed-orders to restore 40 sample orders after clearing.`);
    return;
  }
  // Storage proof images correspond to orders. Delete them before documents so
  // an interrupted run can be resumed without orphaned files.
  for (const file of proofs) await file.delete();
  for (const item of plan) {
    await db.recursiveDelete(item.ref);
    console.log(`Cleared ${item.label}`);
  }
  for (const branch of duplicateBranches) {
    await db.recursiveDelete(branch.ref);
    console.log(`Removed duplicate branch ${branch.id}`);
  }
  if (seedOrders) {
    execFileSync(process.execPath, [join(dirname(fileURLToPath(import.meta.url)), "seed.mjs"), "--orders-only"], {
      stdio: "inherit",
      env: process.env,
    });
  }
  console.log("Demo activity reset complete.");
}

run().catch((error) => {
  console.error("Reset failed:", error);
  process.exitCode = 1;
});
