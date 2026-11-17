# hello-world-ts — AI-агент для автоматизації розробки та CI/CD

**Дисципліна:** Автоматизація проєктування комп'ютерних систем (АПКС)
**Лабораторна робота:** № 1 «Проєктування AI-агента для автоматизації розробки та CI/CD»
**Студент:** Запливаний Данііл Валерійович
**Група:** КІ-401
**Варіант:** 6 — TypeScript, npm scripts, Vitest

## Що це
Репозиторій містить два результати:

1. **AI-агент `build-engineer`** у форматі GitHub Copilot (VS Code): маніфест, три skills,
   шість prompt-команд і оркестратор `/init-all`. Він уміє з нуля створити, зібрати, протестувати
   та перевірити проєкт нижче. Файли агента: каталог `.github/`.
2. **Кросплатформний проєкт Hello World на TypeScript**, згенерований цим агентом:
   виконуваний файл `hello`, юніт-тест `BasicAddition` (Vitest), скрипти `ci.sh`/`ci.bat`
   і GitHub Actions для Windows, Linux і macOS.

## Гілки
| Гілка | Вміст |
|-------|-------|
| `develop` | лише агент (`.github/agents`, `.github/prompts`, `.github/skills`) і документація. Запуск `/init-all` на цій гілці відтворює вміст `feature/*`. |
| `feature/lab1-hello-world` | повний результат: агент + проєкт + тести + CI + журнал AI. |
| `master` | стабільна гілка після злиття. |

## Швидкий старт: запуск агента
1. Відкрити репозиторій у VS Code з розширенням GitHub Copilot (Copilot Chat).
2. У Copilot Chat обрати агента **build-engineer** (меню агентів) або просто ввести команду.
3. Ввести `/init-all` — оркестратор послідовно виконає `/git-init`, `/create-project`,
   `/create-build`, `/create-actions`, `/check` і покаже звіт.
4. Для перевірки без змін ввести `/check` (або запустити `scripts/check.sh` у терміналі).

Детальніше: [docs/usage.md](docs/usage.md). Архітектура агента: [docs/architecture.md](docs/architecture.md).
Журнал взаємодії з AI: [docs/ai-log.md](docs/ai-log.md).

## Швидкий старт: запуск проєкту
```bash
npm ci            # залежності
npm run build     # tsc → dist/, обгортки dist/hello і dist/hello.cmd
npm test          # vitest: BasicAddition + тести greet()
./dist/hello      # Linux/macOS → Hello, World!
dist\hello.cmd    # Windows     → Hello, World!
./ci.sh           # повний локальний прогін, ідентичний CI (Windows: ci.bat)
```

## CI
Workflow `.github/workflows/ci.yml` запускається на push і pull request до `develop`/`master`,
у матриці `ubuntu-latest`, `windows-latest`, `macos-latest`, і викликає лише `ci.sh`/`ci.bat`.
Зібраний `dist/` зберігається як артефакт `hello-<os>`.

## Структура
```
.github/agents/build-engineer.agent.md   маніфест агента
.github/skills/*/SKILL.md                skills: project-scaffold, build-and-test, github-actions
.github/prompts/*.prompt.md              commands: git-init, create-project, create-build, create-actions, check, init
.github/workflows/ci.yml                 CI для трьох ОС
src/lib.ts, src/hello.ts                 вихідний код
tests/hello.test.ts                      юніт-тести (Vitest)
bin/hello, bin/hello.cmd                 обгортки виконуваного файлу
scripts/postbuild.mjs, clean.mjs, check.sh  допоміжні скрипти
ci.sh, ci.bat                            скрипти складання для CI і локально
docs/                                    architecture.md, usage.md, ai-log.md
```
