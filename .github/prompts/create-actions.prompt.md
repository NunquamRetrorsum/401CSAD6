---
description: Створює GitHub Actions workflow .github/workflows/ci.yml з матрицею Windows, Linux і macOS за skill github-actions.
agent: build-engineer
---
# /create-actions

Застосуй skill `.github/skills/github-actions/SKILL.md` з типовими параметрами
(`branches=master, develop, feature/**`; `prBranches=master, develop`; `nodeVersion=22`; `artifactPath=dist/`).

## Передумови
- `/create-build` виконано: `ci.sh` і `ci.bat` існують і `./ci.sh` проходить локально.

## Дії
1. Якщо `.github/workflows/ci.yml` існує — перевір його за правилами skill і повідом, чи відповідає; не перезаписуй без підтвердження.
2. Інакше створи `ci.yml` за правилами 1–5 skill.
3. Виконай «Перевірки» skill і процитуй вивід.
4. Нагадай користувачу: після `git push` відкрити вкладку Actions і переконатися, що три job зелені.

## Очікувані файли
`.github/workflows/ci.yml`.

## Перевірка
```bash
grep -q 'ubuntu-latest' .github/workflows/ci.yml && grep -q 'windows-latest' .github/workflows/ci.yml && grep -q 'macos-latest' .github/workflows/ci.yml
grep -q 'ci.sh' .github/workflows/ci.yml && grep -q 'ci.bat' .github/workflows/ci.yml
! grep -qE 'npm run build|vitest|tsc ' .github/workflows/ci.yml
! grep -q 'secrets\.' .github/workflows/ci.yml
```

## Повідомлення про помилку
- `ci.sh` відсутній → «Спочатку виконайте /create-build.»
- У `ci.yml` знайдено `secrets.` → «Workflow містить посилання на секрети; для цього проєкту вони заборонені.»
- Бракує однієї з ОС → «Матриця неповна: немає `<os>`. Додати?»

## Повторний запуск
Існуючий коректний `ci.yml` не змінюється.
