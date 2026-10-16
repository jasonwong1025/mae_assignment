import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Rules tests share one emulator, so run files one at a time to keep
    // each file's data isolated.
    fileParallelism: false,
    setupFiles: ["./setup.js"],
    // The emulator can be slow to answer the first few calls.
    testTimeout: 15000,
    hookTimeout: 30000,
  },
});
