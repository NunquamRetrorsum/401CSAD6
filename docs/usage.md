# Інструкція запуску

## 1. Запуск AI-агента (GitHub Copilot у VS Code)

### Передумови
- VS Code з розширенням **GitHub Copilot** і **GitHub Copilot Chat**, активний план (Copilot Student).
- Node.js ≥ 20, npm, Git.
- Репозиторій відкрито як робочу папку (щоб VS Code побачив `.github/agents`, `.github/prompts`, `.github/skills`).

### Повний сценарій
1. Перейти на гілку `develop` (на ній лише агент і документація):
   ```bash
   git switch develop
   ```
2. Відкрити Copilot Chat, натиснути «+» (новий чат), у перемикачі режимів (там, де «Ask») обрати
   **Agent**, а в списку агентів — **build-engineer**. У режимі Ask агент не має права створювати файли.
3. Ввести:
   ```
   /init-all
   ```
4. Агент послідовно виконає `/git-init` → `/create-project` → `/create-build` → `/create-actions` → `/check`,
   після кожного кроку запускаючи перевірку. На першій помилці він зупиниться, покаже причину
   і запропонує виправлення; після підтвердження повторить крок.
5. Переглянути створені файли (`git status`, `git diff`), переконатися, що `dist/` і `node_modules/`
   не потрапили до Git, зробити коміт.

### Окремі команди
| Команда | Дія | Змінює файли |
|---------|-----|--------------|
| `/git-init` | перевіряє репозиторій, доповнює `.gitignore`, показує `git status` | так (`.gitignore`) |
| `/create-project` | skill project-scaffold: `src/`, README, `.gitignore` | так |
| `/create-build` | skill build-and-test: `package.json`, `tsconfig.json`, тести, `ci.sh`/`ci.bat` | так |
| `/create-actions` | skill github-actions: `.github/workflows/ci.yml` | так |
| `/check` | 11 перевірок, звіт PASS/FAIL | **ні** |
| `/init-all` | оркестратор усіх кроків вище | так |

Повторний запуск будь-якої команди безпечний: існуючі файли не перезаписуються.

### Те саме без Copilot
Перевірку `/check` можна виконати детерміновано з терміналу:
```bash
./scripts/check.sh
```

## 2. Запуск зібраного проєкту

```bash
npm ci                # встановити залежності з package-lock.json
npm run typecheck     # перевірка типів без генерації
npm run build         # tsc → dist/ + копіювання обгорток
npm test              # vitest run
npm run clean         # видалити dist/ і coverage/
```

Виконуваний файл після `npm run build`:
```bash
./dist/hello            # Linux / macOS
./dist/hello APKS       # з аргументом → Hello, APKS!
dist\hello.cmd          # Windows (cmd / PowerShell)
node dist/hello.js      # будь-яка ОС
```

## 3. Локальна перевірка, ідентична CI
```bash
./ci.sh      # Linux / macOS
ci.bat       # Windows
```
Скрипт виконує: версії → `npm ci` → `typecheck` → `build` → `test` → smoke-тест `dist/hello`.
Код завершення 0 означає, що CI на GitHub також пройде.

## 4. Демонстрація реакції на зламану перевірку
```bash
sed -i.bak 's/return a + b;/return a + b + 1;/' src/lib.ts   # навмисно ламаємо add()
./scripts/check.sh                                          # пункт 7 «Тести» → FAIL
mv src/lib.ts.bak src/lib.ts                                # відновлюємо
./scripts/check.sh                                          # 11/11 PASS
```
