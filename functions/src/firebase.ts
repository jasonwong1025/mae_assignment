import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// One place initialises the Admin SDK, so every module can import `db`
// without caring which file the Functions runtime loads first.
initializeApp();
export const db = getFirestore();
export const region = "asia-southeast1";
