---
description: Перевіряє проєкт без змін - структуру, конфігурацію, складання, тести, виконуваний файл, YAML workflow і стан Git. Повертає звіт PASS/FAIL по кожному пункту.
agent: build-engineer
---
# /check

**Ця команда нічого не змінює.** Вона лише читає файли і запускає команди перевірки.
Якщо щось не так — повідом, що саме, і яку команду (`/create-project`, `/create-build`, `/create-actions`) запустити для виправлення. Не виправляй сам.

## Передумови
Немає. Команду можна запускати в будь-якому стані проєкту.

## Спосіб виконання
Якщо доступний bash (Linux, macOS, Git Bash на Windows) — запусти `./scripts/check.sh` і
процитуй його звіт: він реалізує рівно ці 11 пунктів. Інакше виконай пункти вручну за таблицею нижче.

## Пункти перевірки
Для кожного пункту виконай команду, зафіксуй PASS або FAIL і процитуй ключовий рядок виводу.

| # | Пункт | Команда / умова |
|---|-------|-----------------|
| 1 | Маніфест агента | `.github/agents/build-engineer.agent.md` існує, містить розділи «Роль», «Заборонені дії», «Критерії успішного завершення» |
| 2 | Skills | у `.github/skills/*/SKILL.md` є `project-scaffold`, `build-and-test`, `github-actions`; кожен має «Вхідні дані», «Результат», «Перевірки» |
| 3 | Commands | у `.github/prompts/` є `git-init`, `create-project`, `create-build`, `create-actions`, `check`, `init` |
| 4 | Структура | `src/hello.ts`, `src/lib.ts`, `tests/hello.test.ts`, `README.md`, `docs/architecture.md`, `docs/usage.md`, `.gitignore` |
| 5 | Конфігурація | `package.json` має скрипти `build`, `test`; `tsconfig.json` має `"types": ["node"]` |
| 6 | Складання | `npm run build` → код 0; існують `dist/hello.js`, `dist/hello`, `dist/hello.cmd` |
| 7 | Тести | `npm test` → код 0, у виводі `BasicAddition` і `passed` |
| 8 | Виконуваний файл | `./dist/hello` (Windows: `dist\hello.cmd`) виводить `Hello, World!` |
| 9 | CI-скрипти | `ci.sh` і `ci.bat` існують; `./ci.sh` → код 0 |
| 10 | Workflow | `ci.yml` містить `ubuntu-latest`, `windows-latest`, `macos-latest`, викликає `ci.sh`/`ci.bat`, не містить `secrets.` |
| 11 | Git | `git status --porcelain` не містить `dist/`, `node_modules/`, `coverage/`, `.env` |

## Формат звіту
```
/check — звіт
 1. Маніфест агента ............ PASS
 2. Skills ..................... PASS
 ...
 7. Тести ...................... FAIL  (tests/hello.test.ts: BasicAddition expected 5, received 6)
Підсумок: 10/11 PASS. Проєкт НЕ ГОТОВИЙ. Виправте пункт 7 (див. tests/hello.test.ts або src/lib.ts).
```
Якщо всі PASS: «Підсумок: 11/11 PASS. Проєкт готовий.»

## Повідомлення про помилку
Команда ніколи не «падає» сама — кожна невдача перетворюється на FAIL у звіті.
Виняток: якщо `node`/`npm` не встановлені — «Неможливо виконати перевірку: Node.js не знайдено.»
