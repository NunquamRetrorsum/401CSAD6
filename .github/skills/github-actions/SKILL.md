---
name: github-actions
description: Створює GitHub Actions workflow .github/workflows/ci.yml з матрицею Windows, Linux і macOS, який виконує checkout, налаштування Node.js, запуск ci.sh / ci.bat і зберігає зібраний виконуваний файл як артефакт. Використовуй після build-and-test.
---

# Skill: github-actions

## Коли застосовувати
- Користувач просить «налаштувати CI», «GitHub Actions», або викликає `/create-actions`.
- Оркестратор `/init` дійшов до кроку 4.
- Треба перевірити, що workflow містить усі три ОС (режим перевірки).

## Передумова
`ci.sh` і `ci.bat` існують і проходять локально (skill `build-and-test`).

## Вхідні дані
| Параметр | Типове значення | Опис |
|----------|-----------------|------|
| `branches` | `master, develop, feature/**` | Гілки, на push до яких запускається CI. |
| `prBranches` | `master, develop` | Гілки, PR до яких запускають CI. |
| `nodeVersion` | `22` | Версія для `actions/setup-node`. |
| `artifactPath` | `dist/` | Що вивантажити як артефакт. |

## Правила вмісту workflow
1. Одна job `build-and-test` зі `strategy.matrix.os: [ubuntu-latest, windows-latest, macos-latest]`,
   `fail-fast: false`, щоб бачити результат кожної ОС.
2. Кроки: `actions/checkout@v4` → `actions/setup-node@v4` (з `cache: npm`) →
   `./ci.sh` для `runner.os != 'Windows'` → `ci.bat` через `shell: cmd` для Windows →
   `actions/upload-artifact@v4` з `name: hello-${{ matrix.os }}`, `path: dist/`, `if-no-files-found: error`.
3. **Workflow не містить команд складання** (`npm run build`, `tsc`, `vitest`) — лише виклик
   `ci.sh`/`ci.bat`. Уся логіка складання живе у скриптах, щоб її можна було повторити локально.
4. `permissions: contents: read` — мінімальні права.
5. Жодних секретів, токенів чи `${{ secrets.* }}` у файлі.

## Результат
`.github/workflows/ci.yml`.

## Перевірки
```bash
test -f .github/workflows/ci.yml
grep -q 'ubuntu-latest' .github/workflows/ci.yml
grep -q 'windows-latest' .github/workflows/ci.yml
grep -q 'macos-latest' .github/workflows/ci.yml
grep -q 'ci.sh' .github/workflows/ci.yml && grep -q 'ci.bat' .github/workflows/ci.yml
! grep -qE 'npm run build|vitest|tsc ' .github/workflows/ci.yml   # логіка складання не у workflow
! grep -q 'secrets\.' .github/workflows/ci.yml
node -e "require('node:fs').readFileSync('.github/workflows/ci.yml','utf8')"  # файл читається
```
Після push: у вкладці Actions три зелені job, у кожному є артефакт `hello-<os>`.

## Приклад
**Вхід:** типові значення.
**Очікуваний результат:** workflow `CI` з трьома job `ubuntu-latest`, `windows-latest`,
`macos-latest`, кожен ~1 хв, артефакти `hello-ubuntu-latest`, `hello-windows-latest`, `hello-macos-latest`.

## Типовий сценарій помилки
**Симптом:** job `windows-latest` падає з `'.' is not recognized as an internal or external command`.
**Причина:** на Windows крок запускає `./ci.sh` у `cmd`, або `ci.bat` викликано без `shell: cmd`
(типова оболонка на Windows-runner — PowerShell).
**Дія:** розділити кроки умовами `if: runner.os == 'Windows'` / `!= 'Windows'`, для Windows
вказати `shell: cmd` і `run: ci.bat`.
