import { afterAll, afterEach, beforeAll } from "vitest";
import { newTestEnv } from "./helpers.js";

// One emulator-backed environment for the whole run, with data cleared
// between tests so they do not leak into each other. Exposed on globalThis
// so test files can grab it without importing from here.
let testEnv;

beforeAll(async () => {
  testEnv = await newTestEnv();
  globalThis.__TEST_ENV__ = testEnv;
});

afterEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
});

afterAll(async () => {
  await testEnv.cleanup();
});
