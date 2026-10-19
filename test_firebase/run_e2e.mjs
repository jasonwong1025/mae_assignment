import { spawn } from "node:child_process";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

const directory = dirname(fileURLToPath(import.meta.url));
const device = process.argv[2];
if (process.argv.length > 3 || (device && !/^[\w.:-]+$/.test(device))) {
  console.error("Usage: npm run e2e -- [device-id]");
  process.exit(2);
}

const env = {
  ...process.env,
  FIRESTORE_EMULATOR_HOST:
    process.env.FIRESTORE_EMULATOR_HOST ?? "localhost:8085",
  FIREBASE_AUTH_EMULATOR_HOST:
    process.env.FIREBASE_AUTH_EMULATOR_HOST ?? "localhost:9099",
};

function run(command, args, cwd) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      env,
      stdio: "inherit",
      shell: process.platform === "win32" && command === "patrol",
    });
    child.once("error", reject);
    child.once("exit", (code, signal) => {
      resolve(signal ? 1 : (code ?? 1));
    });
  });
}

try {
  console.log("Resetting the Firebase emulator fixtures for Patrol...");
  const seedResult = await run(process.execPath, ["seed.mjs", "--with-customer"], directory);
  if (seedResult !== 0) {
    process.exitCode = seedResult;
  } else {
    const args = ["test", "--dart-define=USE_FIREBASE_EMULATOR=true"];
    if (device) args.push("--device", device);
    process.exitCode = await run("patrol", args, dirname(directory));
  }
} catch (error) {
  console.error("E2E setup failed:", error);
  process.exitCode = 1;
}
