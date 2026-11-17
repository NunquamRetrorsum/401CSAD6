---
name: project-scaffold
description: Створює мінімальний кросплатформний каркас проєкту Hello World на TypeScript - структуру каталогів, вихідний файл, README і .gitignore. Використовуй, коли треба започаткувати новий проєкт або перевірити, що каркас повний.
---

# Skill: project-scaffold

## Коли застосовувати
- Користувач просить «створити проєкт», «каркас», «scaffold», або викликає `/create-project`.
- Оркестратор `/init` дійшов до кроку 2.
- Треба перевірити, чи наявний каркас повний (режим перевірки, без змін).

## Вхідні дані
| Параметр | Обов'язковий | Типове значення | Опис |
|----------|--------------|-----------------|------|
| `language` | так | `typescript` | Мова проєкту. Цей skill підтримує лише `typescript`. |
| `projectName` | так | `hello-world-ts` | Назва пакета в `package.json`, ім'я каталогу. |
| `author` | ні | з README | ПІБ, група, варіант для README. |

Якщо `language` не `typescript` — зупинись і повідом: «skill project-scaffold підтримує лише TypeScript».

## Результат (вихідні файли)
```
.
├── src/
│   ├── lib.ts        # greet(), add() — без побічних ефектів
│   └── hello.ts      # точка входу з shebang, друкує greet()
├── tests/            # порожній каталог; тести створює build-and-test
├── docs/             # порожній каталог; документацію доповнюють команди
├── README.md         # ПІБ, група, варіант, опис, як запустити агента і проєкт
└── .gitignore        # node_modules, dist, build, coverage, .env, логи
```
`package.json` тут створюється **мінімальним** (name, version, type=module, private);
скрипти складання додає skill `build-and-test`.

## Кроки
1. Переконайся, що поточний каталог — корінь Git-репозиторію (`git rev-parse --show-toplevel`).
2. Для кожного файлу з переліку: якщо існує — порівняй з вимогами і пропусти; якщо ні — створи.
3. `src/lib.ts` має експортувати `greet(name = "World"): string` → `Hello, ${name}!` та `add(a, b)`.
4. `src/hello.ts` має починатися з `#!/usr/bin/env node`, імпортувати `greet` з `./lib.js`
   (розширення `.js` обов'язкове для NodeNext) і виводити результат у `console.log`.
5. `.gitignore` має містити щонайменше: `node_modules/`, `dist/`, `build/`, `coverage/`, `.env`, `*.log`.
6. README має містити: ПІБ, групу, варіант, назву проєкту, команди запуску агента та проєкту.

## Перевірки
```bash
test -f src/hello.ts && test -f src/lib.ts && test -f README.md && test -f .gitignore
head -1 src/hello.ts | grep -q '^#!/usr/bin/env node'
grep -q 'export function greet' src/lib.ts
grep -q 'node_modules' .gitignore && grep -q 'dist' .gitignore
```
Усі команди мають завершитися з кодом 0.

## Приклад
**Вхід:** `language=typescript`, `projectName=hello-world-ts`.
**Очікуваний результат:** створено 5 файлів (перелік вище), вивід:
```
створено: src/lib.ts, src/hello.ts, README.md, .gitignore, package.json
пропущено: —
перевірки: 4/4 OK
```

## Типовий сценарій помилки
**Симптом:** `src/hello.ts` імпортує `./lib` без розширення → після складання
`node dist/hello.js` падає з `ERR_MODULE_NOT_FOUND`.
**Причина:** у режимі `module: NodeNext` Node вимагає явне `.js` у відносних імпортах.
**Дія:** замінити імпорт на `./lib.js`, повторити перевірку `node dist/hello.js` після складання.
