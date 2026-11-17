# Архітектура AI-агента build-engineer

## 1. Яку проблему вирішує агент
Створення навіть мінімального кросплатформного проєкту вимагає десятка узгоджених файлів:
код, конфігурація компілятора, тестовий фреймворк, скрипти складання для двох оболонок
(bash і cmd), workflow для трьох ОС, `.gitignore`, документація. Помилка в одному з них
(наприклад, відсутнє `"types": ["node"]` у `tsconfig.json`) ламає весь ланцюжок, а виявляється
лише на CI. Агент `build-engineer` перетворює цей процес на повторюваний сценарій із
перевіркою після кожного кроку та зупинкою на першій помилці.

## 2. Формат і відповідність файлів ролям
Використано стандартний формат **GitHub Copilot для VS Code**:

| Роль у методичці | Файл(и) у репозиторії | Формат Copilot |
|------------------|-----------------------|----------------|
| Agent manifest | `.github/agents/build-engineer.agent.md` | custom agent (`*.agent.md`, YAML frontmatter `name`, `description`, `tools`) |
| Skill «створення проєкту» | `.github/skills/project-scaffold/SKILL.md` | Agent Skill (`SKILL.md`, frontmatter `name`, `description`) |
| Skill «складання і тестування» | `.github/skills/build-and-test/SKILL.md` | Agent Skill |
| Skill «GitHub Actions» | `.github/skills/github-actions/SKILL.md` | Agent Skill |
| Commands | `.github/prompts/{git-init,create-project,create-build,create-actions,check}.prompt.md` | prompt file (`*.prompt.md`, викликається як `/назва`) |
| Orchestrator (`init` у методичці) | `.github/prompts/init-all.prompt.md` | prompt file, що послідовно посилається на інші команди. Назва `init-all`, бо вбудована команда Copilot Chat `/init` (генерація `copilot-instructions.md`) перекриває однойменний prompt-файл |
| Детермінована реалізація `/check` | `scripts/check.sh` | звичайний bash-скрипт; `/check` запускає його або повторює ті самі 11 перевірок |

## 3. Схема взаємодії

```
Користувач
   │  /init-all
   ▼
┌──────────────────────── build-engineer.agent.md ────────────────────────┐
│ роль · межі відповідальності · заборони · критерії завершення          │
│                                                                        │
│  init-all.prompt.md (оркестратор)                                          │
│   1 ─► git-init-all.prompt.md ──────────────────────► .gitignore, git status│
│   2 ─► create-project.prompt.md ─► SKILL project-scaffold ─► src/, README│
│   3 ─► create-build.prompt.md ───► SKILL build-and-test ──► package.json,│
│                                                   tsconfig, tests/, ci.sh/ci.bat│
│   4 ─► create-actions.prompt.md ─► SKILL github-actions ─► ci.yml       │
│   5 ─► check.prompt.md ─────────► scripts/check.sh ─────► звіт 11/11    │
│                                                                        │
│  після кожного кроку: перевірка кроку; FAIL ⇒ стоп, звіт, без кроку N+1│
└────────────────────────────────────────────────────────────────────────┘
```

## 4. Які дані передаються між етапами
| З кроку | У крок | Дані |
|---------|--------|------|
| git-init | create-project | корінь репозиторію; підтвердження, що `.gitignore` ігнорує `dist/`, `node_modules/` |
| create-project | create-build | `projectName`, шляхи `src/lib.ts`, `src/hello.ts`, факт наявності `package.json` |
| create-build | create-actions | назви скриптів `ci.sh`, `ci.bat`, результат їх локального запуску (код 0) |
| create-actions | check | шлях `.github/workflows/ci.yml` |
| check | користувач | звіт PASS/FAIL по 11 пунктах, перелік команд для виправлення |

Дані передаються через файлову систему (кожна команда перевіряє наявність результатів попередньої),
а не через прихований стан чату. Тому кожну команду можна запустити окремо і повторно.

## 5. Як оркестратор обробляє помилки
1. **Перевірка передумов.** Кожна команда спочатку перевіряє результати попередньої
   (наприклад, `/create-build` вимагає `src/hello.ts`). Якщо їх немає — повідомляє, яку команду запустити.
2. **Перевірка результату.** Після дії команда запускає свої перевірки (`npm run build`, `npm test`,
   smoke-тест `dist/hello`, grep по `ci.yml`) і цитує фактичний вивід.
3. **Зупинка на першій помилці.** `/init-all` не переходить до кроку N+1, доки перевірка кроку N не пройшла.
   Звіт явно каже «ЗУПИНЕНО на кроці N. Кроки N+1… не виконувались».
4. **Виправлення лише за підтвердженням.** Агент пропонує diff, застосовує після «так», повторює перевірку.
5. **Без прихованих успіхів.** Критерії завершення у маніфесті — чек-лист; якщо хоч один пункт не виконано,
   звіт має містити «НЕ ЗАВЕРШЕНО».
6. **Ідемпотентність.** Повторний `/init-all` на готовому проєкті нічого не перезаписує і завершується
   «усі кроки пропущено, /check 11/11 PASS».

## 6. Межі безпеки
Агент не виконує `git commit`/`push`/`reset`/`rebase`, не видаляє нічого, крім `dist/` і `coverage/`
через `npm run clean`, не читає й не записує секрети, не додає залежностей поза skill.
Workflow має `permissions: contents: read` і не посилається на `secrets.*`.

## 7. Чому логіка складання у `ci.sh`/`ci.bat`, а не у `ci.yml`
Методичка вимагає, щоб `ci.yml` лише викликав скрипти складання. Це дає:
- одні й ті самі кроки локально і на CI (`./ci.sh` на ноутбуці = job на GitHub);
- простий YAML без дублювання для трьох ОС;
- можливість перевірити складання без доступу до GitHub Actions.
Ціна — два скрипти (bash і cmd), які треба тримати синхронними; це задача skill `build-and-test`.
