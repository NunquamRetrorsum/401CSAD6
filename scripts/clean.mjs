// Видаляє лише каталоги результатів складання (dist, coverage).
// Навмисно не торкається node_modules, src, tests чи файлів Git.
import { rmSync } from "node:fs";

for (const dir of ["dist", "coverage"]) {
  rmSync(dir, { recursive: true, force: true });
}
console.log("clean: dist/ і coverage/ видалено");
