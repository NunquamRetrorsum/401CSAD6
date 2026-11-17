---
description: Створює конфігурацію складання (tsc, npm scripts), юніт-тест BasicAddition на Vitest, виконуваний файл hello та скрипти ci.sh / ci.bat за skill build-and-test.
agent: build-engineer
tools: ['edit', 'search', 'runCommands', 'runTasks', 'problems', 'testFailure']
---
# /create-build

Застосуй skill `.github/skills/build-and-test/SKILL.md` з параметрами:
`testFramework=vitest`, `nodeVersion=22`, `testName=BasicAddition`.

## Передумови
- `/create-project` виконано: `src/lib.ts`, `src/hello.ts`, `package.json` існують.
- Node.js ≥ 20 і npm доступні (`node --version`, `npm --version`).

## Дії
1. Підзадача **3.1 build-config**: `package.json` (скрипти, devDependencies), `tsconfig.json`,
   `scripts/postbuild.mjs`, `scripts/clean.mjs`, `bin/hello`, `bin/hello.cmd`.
2. Підзадача **3.2 unit-test**: `vitest.config.ts`, `tests/hello.test.ts` з тестом `BasicAddition`.
3. Підзадача **3.3 ci-scripts**: `ci.sh`, `ci.bat`.
4. Виконай `npm install` (лише якщо `node_modules/` немає або `package-lock.json` застарів).
5. Виконай «Перевірки» skill: `npm run build`, `npm test`, `./dist/hello`, `./ci.sh`. Процитуй вивід.

## Очікувані файли
`package.json`, `package-lock.json`, `tsconfig.json`, `vitest.config.ts`, `tests/hello.test.ts`,
`scripts/postbuild.mjs`, `scripts/clean.mjs`, `bin/hello`, `bin/hello.cmd`, `ci.sh`, `ci.bat`.

## Перевірка
```bash
npm run build && test -x dist/hello && test -f dist/hello.cmd
npm test 2>&1 | grep -q BasicAddition
[ "$(./dist/hello)" = "Hello, World!" ]
./ci.sh
```

## Повідомлення про помилку
- `error TS2591: Cannot find name 'process'` → «У tsconfig.json бракує `"types": ["node"]`. Додати?»
- `npm test` не знаходить тестів → «vitest.config.ts має include `tests/**/*.test.ts`; перевірте шлях.»
- `./dist/hello` виводить не `Hello, World!` → «Smoke-тест провалено: отримано `<вивід>`. Перевірте src/lib.ts.»

## Повторний запуск
Існуючі файли не перезаписуються; `package.json` оновлюється лише відсутніми ключами
(скрипти/залежності додаються, а не замінюються).
