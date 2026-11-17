---
description: Створює початковий кросплатформний проєкт Hello World на TypeScript за skill project-scaffold.
agent: build-engineer
tools: ['edit', 'search', 'runCommands']
---
# /create-project

Застосуй skill `.github/skills/project-scaffold/SKILL.md` з параметрами:
`language=typescript`, `projectName=hello-world-ts`.

## Передумови
- `/git-init` виконано: репозиторій існує, `.gitignore` є.

## Дії
1. Прочитай SKILL.md і виконай його кроки 1–6.
2. Для кожного файлу повідом: **створено** / **пропущено (існує і відповідає)** / **потребує правки (покажи diff)**.
3. Виконай розділ «Перевірки» skill і процитуй вивід.

## Очікувані файли
`src/lib.ts`, `src/hello.ts`, `README.md`, `.gitignore`, мінімальний `package.json`, каталоги `tests/`, `docs/`.

## Перевірка
```bash
test -f src/hello.ts && test -f src/lib.ts && test -f README.md
head -1 src/hello.ts | grep -q '^#!/usr/bin/env node'
grep -q 'export function greet' src/lib.ts
```

## Повідомлення про помилку
- `.gitignore` відсутній → «Спочатку виконайте /git-init.»
- `src/hello.ts` існує, але без shebang → «src/hello.ts не відповідає skill: бракує `#!/usr/bin/env node`. Застосувати правку? (так/ні)»

## Повторний запуск
Не перезаписує існуючі файли, не дублює рядки в `.gitignore`.
