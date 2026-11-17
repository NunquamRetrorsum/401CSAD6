---
name: build-and-test
description: Налаштовує систему складання TypeScript (tsc + npm scripts), створює юніт-тест BasicAddition на Vitest, виконуваний файл hello з обгортками та кросплатформні скрипти ci.sh / ci.bat. Використовуй після project-scaffold, коли треба зробити проєкт збірним і тестованим.
---

# Skill: build-and-test

## Коли застосовувати
- Користувач просить «налаштувати складання», «додати тести», або викликає `/create-build`.
- Оркестратор `/init` дійшов до кроку 3.
- Треба перевірити, що складання і тести працюють (режим перевірки).

## Передумова
Каркас зі skill `project-scaffold` існує (`src/lib.ts`, `src/hello.ts`, `package.json`).

## Вхідні дані
| Параметр | Типове значення | Опис |
|----------|-----------------|------|
| `testFramework` | `vitest` | Єдине підтримуване значення. |
| `nodeVersion` | `22` | Мінімальна версія для `engines` і CI. |
| `testName` | `BasicAddition` | Назва обов'язкового тесту. |

## Підзадачі (можна викликати окремо)
### 3.1 build-config
- `package.json`: devDependencies `typescript`, `vitest`, `@types/node`; скрипти
  `build` (`tsc -p tsconfig.json && node scripts/postbuild.mjs`), `test` (`vitest run`),
  `typecheck`, `start`, `clean`, `check`.
- `tsconfig.json`: `target ES2022`, `module NodeNext`, `rootDir src`, `outDir dist`,
  `strict true`, **`types: ["node"]`** (без цього `process` не знайдено у TypeScript 7).
- `scripts/postbuild.mjs`: копіює `bin/hello` та `bin/hello.cmd` у `dist/`, виставляє `chmod 755`.
- `scripts/clean.mjs`: видаляє лише `dist/` і `coverage/`.
- `bin/hello` (sh) і `bin/hello.cmd` (cmd) — обгортки, що запускають `dist/hello.js` через Node.

### 3.2 unit-test
- `vitest.config.ts` з `include: ["tests/**/*.test.ts"]`.
- `tests/hello.test.ts`: тест `BasicAddition` для `add()` і щонайменше один тест для `greet()`.

### 3.3 ci-scripts
- `ci.sh` (bash, `set -euo pipefail`) і `ci.bat` (cmd, `|| goto :fail`) з однаковими кроками:
  версії → `npm ci` → `typecheck` → `build` → `test` → smoke-тест, який запускає
  `dist/hello` і порівнює вивід з `Hello, World!`.

## Результат
`package.json` (оновлено), `tsconfig.json`, `vitest.config.ts`, `tests/hello.test.ts`,
`scripts/postbuild.mjs`, `scripts/clean.mjs`, `bin/hello`, `bin/hello.cmd`, `ci.sh`, `ci.bat`,
`package-lock.json` (після `npm install`).

## Перевірки
```bash
npm ci
npm run build                 # код 0, існують dist/hello.js, dist/hello, dist/hello.cmd
npm test                      # код 0, у виводі "BasicAddition" і "passed"
./dist/hello                  # виводить рівно: Hello, World!
./ci.sh                       # код 0
git status --porcelain | grep -E '^\?\? (dist|node_modules|coverage)/' && echo "ПОМИЛКА: артефакти не в .gitignore" || true
```

## Приклад
**Вхід:** `testFramework=vitest`, `testName=BasicAddition`.
**Очікуваний результат:** `npm test` показує
```
 ✓ tests/hello.test.ts (3 tests)
 Test Files  1 passed (1)
      Tests  3 passed (3)
```
і `./dist/hello` друкує `Hello, World!`.

## Типовий сценарій помилки
**Симптом:** `npm run build` → `error TS2591: Cannot find name 'process'`.
**Причина:** `tsconfig.json` не містить `"types": ["node"]`, тож `@types/node` не підключено.
**Дія:** додати `"types": ["node"]` до `compilerOptions`, повторити `npm run build`.
Не «виправляти» це заміною `process.argv` на щось інше — це маскує, а не усуває проблему.
