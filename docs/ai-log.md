# Журнал взаємодії з AI

**AI-інструменти:** Claude Code (модель Claude Fable 5.1) у терміналі — проєктування агента, генерація
файлів, локальні перевірки; GitHub Copilot Chat у VS Code — запуск агента `build-engineer`
(`/init-all`, `/check`) на гілці `develop` для відтворення результату (розділ 7).
**Дата:** 2026-11-17.
**Правило:** жоден згенерований файл не прийнято без перегляду та запуску перевірки.

---

## 1. Аналіз вимог
**Запит:** «переглянь методичку до лабораторної 1 і скажи, що треба зробити» (додано `task1.pdf`).
**Відповідь AI (суть):** виділено обов'язкові артефакти — маніфест агента, 3 skills, 6 commands
(5 операцій + оркестратор `init`), Hello World за варіантом, тест `BasicAddition`, `ci.sh`/`ci.bat`,
`ci.yml` з матрицею трьох ОС, гілки `develop`/`feature`, PR `lab1/finish`, журнал AI, документація.
**Рішення студента:** варіант 6 → TypeScript + npm scripts + Vitest. Формат агента — GitHub Copilot
(`.github/agents`, `.github/prompts`, `.github/skills`), як у рекомендованій структурі методички.

## 2. Проєктні рішення (обговорено з AI, затверджено студентом)
| Питання | Варіанти | Рішення і чому |
|---------|----------|----------------|
| Що є «виконуваним файлом hello» у TS-проєкті | (а) `dist/hello.js` + обгортки `hello`/`hello.cmd`; (б) справжній бінарник через Node SEA | **(а)**: стабільно на трьох ОС, без проблем із підписом на macOS; `dist/` вивантажується як артефакт CI |
| Де логіка складання | у `ci.yml` чи у `ci.sh`/`ci.bat` | у скриптах, як вимагає методичка; `ci.yml` лише їх викликає |
| Структура коду | один файл чи код + бібліотека | `src/lib.ts` (чисті функції) + `src/hello.ts` (вивід), щоб тестувати без побічних ефектів |
| Файлові операції після `tsc` | `cp`/`chmod` у npm-скрипті чи Node-скрипт | `scripts/postbuild.mjs` на Node, бо `cp` не існує у cmd на Windows |
| Видимість репозиторію | публічний / приватний | публічний: безлімітні хвилини Actions для трьох ОС, викладач бачить без запрошення |

## 3. Генерація каркасу та системи складання
**Запит:** «створи package.json, tsconfig.json, src/lib.ts, src/hello.ts, tests/hello.test.ts, обгортки bin/, scripts/postbuild.mjs; встанови typescript, vitest, @types/node».
**Результат:** файли створено, `npm install -D typescript vitest @types/node` → `typescript@7.0.2`, `vitest@4.1.12`, `@types/node@26.6.6`.

### 3.1 Помилка № 1 (справжня) і виправлення
**Команда:** `npm run build`
**Вивід:**
```
src/hello.ts(9,14): error TS2591: Cannot find name 'process'. Do you need to install type
definitions for node? Try `npm i --save-dev @types/node` and then add 'node' to the types
field in your tsconfig.
```
**Аналіз AI:** `@types/node` встановлено, але TypeScript 7 не підхопив його автоматично;
у `tsconfig.json` бракує `"types": ["node"]`.
**Відхилений варіант:** замінити `process.argv` на щось без `process` — це маскує проблему,
а не усуває її; будь-який наступний код із Node API зламається знову.
**Виправлення:** додано `"types": ["node"]` у `compilerOptions`.
**Повторна перевірка:**
```
postbuild: dist/hello, dist/hello.cmd, dist/hello.js готові
$ ./dist/hello
Hello, World!
 ✓ tests/hello.test.ts (3 tests) 1ms
 Test Files  1 passed (1)
      Tests  3 passed (3)
```
**Що змінено в агенті:** сценарій цієї помилки додано до skill `build-and-test`
(розділ «Типовий сценарій помилки») і до `create-build.prompt.md` («Повідомлення про помилку»),
щоб агент розпізнавав її при наступних запусках.

## 4. CI-скрипти та workflow
**Запит:** «напиши ci.sh і ci.bat з однаковими кроками та ci.yml, який лише їх викликає у матриці ubuntu/windows/macos».
**Результат:** `ci.sh` (`set -euo pipefail`, smoke-тест порівнює вивід `dist/hello` з `Hello, World!`),
`ci.bat` (`|| goto :fail`), `ci.yml` (одна job, `fail-fast: false`, `actions/checkout@v5`,
`actions/setup-node@v5` з кешем npm, крок для Windows через `shell: cmd`, `upload-artifact@v5` з `dist/`).
**Локальна перевірка `./ci.sh`:**
```
==> Версії інструментів
==> Встановлення залежностей (npm ci)
==> Перевірка типів
==> Складання (tsc + postbuild)
==> Юніт-тести (vitest)
 Test Files  1 passed (1)
      Tests  3 passed (3)
==> Smoke-тест виконуваного файлу dist/hello
Hello, World!
==> Готово: складання, тести та smoke-тест пройшли успішно
```

## 5. Агент: маніфест, skills, commands
**Запит:** «напиши маніфест build-engineer з роллю, межами, заборонами, критеріями; три skills із входами,
виходами, перевірками та сценарієм помилки; шість prompt-команд із передумовами, діями, перевірками,
повідомленнями про помилку; оркестратор має зупинятись на першій помилці і бути ідемпотентним».
**Результат:** 10 файлів у `.github/`. Перегляд студентом: перевірено, що кожна command посилається
на конкретний skill, що `/check` нічого не змінює, що заборони включають `git push --force`, `reset --hard`,
секрети, видалення файлів.

## 6. Перевірка `/check` і навмисно зламана перевірка
**Запит:** «зроби scripts/check.sh, який реалізує 11 пунктів /check, і покажи, як він реагує на зламаний код».
**Перший запуск** показав чесний FAIL, бо README ще не було написано:
```
  4. Структура ................. FAIL  (бракує README.md)
Підсумок: 10/11 PASS. Проєкт НЕ ГОТОВИЙ.
```
Після створення README і docs — 11/11.

**Навмисна поломка:** у `src/lib.ts` замінено `return a + b;` на `return a + b + 1;`.
```
  7. Тести ..................... FAIL  ( FAIL  tests/hello.test.ts > hello-world-ts > BasicAddition)
  9. CI-скрипти ................ FAIL  (...)
Підсумок: 9/11 PASS. Проєкт НЕ ГОТОВИЙ. Виправте пункти з FAIL.
```
Пункт 9 падає разом із 7, бо `ci.sh` сам запускає тести — це очікувано і показує, що CI теж не пройде.
Після відновлення файлу: `Підсумок: 11/11 PASS. Проєкт готовий.`

### 6.1 Помилка № 2 (виявлена під час відеодемонстрації) і виправлення
**Симптом:** у Copilot Chat на гілці `develop` команда `/init` не створила жодного файлу: агент написав
чернетку інструкцій і запропонував «switch to an editing agent»; у журналі інструментів двічі з'явилось «Read failed».
**Аналіз:** чат був у режимі **Ask**, який не має права змінювати файли; крім того, явний список `tools`
у frontmatter посилався на назви інструментів, які відрізняються між версіями VS Code.
**Виправлення:** (1) з маніфесту та всіх prompt-файлів прибрано рядок `tools:` — агент отримує всі інструменти
за замовчуванням; (2) у `docs/usage.md` уточнено, що перед `/init` потрібно відкрити новий чат, перемкнути режим
на Agent і вибрати агента `build-engineer`.
**Повторна перевірка:** `/init-all` у режимі Agent на гілці `develop` (див. розділ 7).

### 6.2 Помилка № 3 (виявлена під час відеодемонстрації) і виправлення
**Симптом:** у режимі Agent команда `/init` замість оркестратора створила `.github/copilot-instructions.md`
і запропонувала «configure MCP servers». Водночас `/check` відпрацював правильно: 5/11 PASS на гілці `develop`,
де проєкту ще немає.
**Аналіз:** у Copilot Chat є вбудована команда `/init` (генерація інструкцій репозиторію), яка має пріоритет
над prompt-файлом з такою ж назвою.
**Виправлення:** оркестратор перейменовано на `init-all.prompt.md`; усі посилання в маніфесті, командах,
`scripts/check.sh`, README і docs оновлено; адаптацію назви зафіксовано в `docs/architecture.md`,
як вимагає методичка для відмінностей конкретного AI-клієнта. Створений Copilot файл
`copilot-instructions.md` видалено, бо він не є частиною агента.

## 7. Відтворення через Copilot на гілці develop
**Дата:** 2026-11-17, 18:04–18:07. **Режим:** Copilot Chat → Agent → `build-engineer`, новий чат, гілка `develop`
(у робочому дереві лише `.github/`, `docs/`, `README.md`, `.gitignore`, `scripts/check.sh`).

**Крок 0, `/check` до запуску:** 5/11 PASS — агент прочитав skill `build-and-test`, запустив `scripts/check.sh`
і чесно перелічив, чого бракує: `src/hello.ts`, конфігурація `npm run build`/`npm test`, `ci.sh`/`ci.bat`,
`.github/workflows/ci.yml`.

**`/init-all`:** агент послідовно виконав `/git-init` → `/create-project` → `/create-build` → `/create-actions` → `/check`,
на кожному кроці запитуючи підтвердження на запис файлів і запуск команд. Створено: `src/lib.ts`, `src/hello.ts`,
`tests/hello.test.ts`, `package.json`, `package-lock.json`, `tsconfig.json`, `vitest.config.ts`, `bin/hello`, `bin/hello.cmd`,
`scripts/postbuild.mjs`, `scripts/clean.mjs`, `ci.sh`, `ci.bat`, `.github/workflows/ci.yml`.

**`/check` після запуску:** `Підсумок: 11/11 PASS. Проєкт готовий.`

**Навмисна поломка на відео:** у `src/lib.ts` змінено `return a + b;` на `return a + b + 21;`.
`/check` → пункт 7 «Тести» FAIL (`BasicAddition`: expected 5, received 26), пункт 9 «CI-скрипти» FAIL
(`./ci.sh` також падає на тестах); решта PASS, `/check` нічого не змінював.

**Повторний `/init-all` на зламаному проєкті:** крок 1 пройшов (файли на місці, нічого не перезаписано);
на кроці 3 агент помітив змінену логіку `add()`, запустив `npm run build && npm test`, зупинився і попросив
підтвердження на правку; після підтвердження виправив один рядок (`1 file changed +1 −1`), повторив складання,
тести, `./ci.sh`, перевірку workflow і завершив: «Фінальний /check: 11/11 PASS». Це демонструє одночасно
зупинку на першій помилці, виправлення лише за підтвердженням та ідемпотентність (жоден інший файл не змінено).

**Відео:** `lab1-video-init-all.mov` (4 хв 32 с, 2026-11-17 18:03–18:07).

**Порівняння з гілкою `feature/lab1-hello-world`.** Текст файлів відрізняється (агент пише власну редакцію, без
коментарів українською, з іншим групуванням тестів), але функціонально результат той самий: ті самі експорти
`greet`/`add`, тест `BasicAddition`, ті самі npm-скрипти, матриця трьох ОС у `ci.yml`, виклик лише `ci.sh`/`ci.bat`.
Відмінність, яку варто зафіксувати: агент використав `actions/*@v4`, тоді як у `feature` версії оновлено до `v5`;
на результат CI це не впливає, але в skill `github-actions` варто явно вказати версію `v5` як обов'язкову.

Згенерований `src/lib.ts`:
```ts
export function greet(name = "World"): string {
  return `Hello, ${name}!`;
}

export function add(a: number, b: number): number {
  return a + b;
}
```
Згенерований `tests/hello.test.ts`:
```ts
import { describe, expect, it } from "vitest";
import { add, greet } from "../src/lib.js";

describe("BasicAddition", () => {
  it("adds two numbers", () => {
    expect(add(2, 3)).toBe(5);
  });
});

describe("greet", () => {
  it("uses World as the default name", () => {
    expect(greet()).toBe("Hello, World!");
  });

  it("greets the provided name", () => {
    expect(greet("APKS")).toBe("Hello, APKS!");
  });
});
```
Згенеровані файли на `develop` не комітились: ця гілка за задумом містить лише агента; повний результат живе у `feature/*`.

## 8. Прийняті рішення щодо безпеки
- Секрети, токени, вміст `.env` AI не передавались; у workflow немає `secrets.*`.
- `node_modules/`, `dist/`, `coverage/` у `.gitignore`; перевірено `git status` перед кожним комітом.
- Агент не має права на `commit`/`push`; усі коміти зроблено студентом після перегляду diff.
