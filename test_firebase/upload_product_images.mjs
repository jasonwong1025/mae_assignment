// Upload the checked-in generic product photos and link them in Firestore.
// Preview by default; --apply --confirm-project=mae-assignment-grocerly writes.
import { applicationDefault, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { randomUUID } from "node:crypto";
import { stat } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const projectId = "mae-assignment-grocerly";
const bucketName = `${projectId}.firebasestorage.app`;
const ids = ["p-apple", "p-bread", "p-carrot", "p-chicken", "p-eggs", "p-milk", "p-oil", "p-pepper", "p-rice", "p-tomato"];
const args = new Set(process.argv.slice(2));
const confirm = `--confirm-project=${projectId}`;
for (const arg of args) {
  if (!["--apply", confirm].includes(arg)) throw new Error(`Unknown option: ${arg}`);
}
const apply = args.has("--apply");
if (apply && !args.has(confirm)) throw new Error(`Upload requires ${confirm}`);
const emulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
if (emulator !== Boolean(process.env.FIREBASE_STORAGE_EMULATOR_HOST)) {
  throw new Error("Firestore and Storage emulator settings must be used together.");
}
const app = initializeApp({
  projectId,
  storageBucket: bucketName,
  ...(emulator ? {} : { credential: applicationDefault() }),
});
const db = getFirestore(app);
const bucket = getStorage(app).bucket();
const imageDir = join(dirname(fileURLToPath(import.meta.url)), "product-images");

async function run() {
  console.log(`Target: ${emulator ? "emulator" : "LIVE"} / ${projectId}`);
  for (const id of ids) {
    const path = join(imageDir, `${id}.png`);
    const size = (await stat(path)).size;
    if (size >= 5 * 1024 * 1024) throw new Error(`${id} exceeds the Storage rule's 5 MiB limit`);
    const product = db.collection("products").doc(id);
    const snapshot = await product.get();
    if (!snapshot.exists) throw new Error(`Missing catalogue product ${id}; seed catalogue first.`);
    const objectName = `products/${id}/catalogue.png`;
    console.log(`${id}: ${size} bytes -> ${objectName}`);
    if (!apply) continue;
    const file = bucket.file(objectName);
    const [exists] = await file.exists();
    const existingToken = exists
      ? (await file.getMetadata())[0].metadata?.firebaseStorageDownloadTokens?.split(",")[0]
      : undefined;
    const token = existingToken || randomUUID();
    await bucket.upload(path, {
      destination: objectName,
      metadata: {
        contentType: "image/png",
        cacheControl: "public, max-age=3600",
        metadata: { firebaseStorageDownloadTokens: token },
      },
    });
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(objectName)}?alt=media&token=${token}`;
    await product.update({ imageUrls: [url] });
  }
  if (apply) console.log("All ten product photos uploaded and linked.");
  else console.log(`DRY RUN. To upload: node upload_product_images.mjs --apply ${confirm}`);
}

run().catch((error) => {
  console.error("Image upload failed:", error);
  process.exitCode = 1;
});
