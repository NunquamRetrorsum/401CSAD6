// Після tsc: копіює обгортки з bin/ у dist/ і робить їх виконуваними.
// Написано на Node, щоб працювати однаково на Windows, Linux і macOS.
import { chmodSync, copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const dist = "dist";
if (!existsSync(dist)) mkdirSync(dist, { recursive: true });

for (const file of ["hello", "hello.cmd"]) {
  copyFileSync(join("bin", file), join(dist, file));
}

for (const file of ["hello", "hello.js"]) {
  try {
    chmodSync(join(dist, file), 0o755);
  } catch {
    // На Windows chmod не має значення; ігноруємо.
  }
}

console.log("postbuild: dist/hello, dist/hello.cmd, dist/hello.js готові");
