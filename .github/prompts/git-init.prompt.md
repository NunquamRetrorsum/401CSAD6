---
description: Перевіряє Git-репозиторій, створює або доповнює .gitignore і показує стан Git. Нічого не комітить.
agent: build-engineer
tools: ['edit', 'search', 'runCommands']
---
# /git-init

## Передумови
- Поточний каталог — корінь репозиторію або порожній каталог, де можна ініціалізувати Git.
- Git встановлено (`git --version`).

## Дії
1. Виконай `git rev-parse --is-inside-work-tree`. Якщо помилка — виконай `git init -b master` і повідом про це.
2. Перевір `.gitignore`. Якщо немає — створи. Якщо є — **додай** відсутні рядки, не перезаписуючи файл:
   `node_modules/`, `dist/`, `build/`, `coverage/`, `*.tsbuildinfo`, `*.log`, `.env`, `.env.*`, `*.pem`, `*.key`, `.DS_Store`.
3. Виконай `git status --short --branch` і процитуй вивід.
4. Якщо у виводі `git status` є `dist/`, `node_modules/` або `.env` як невідстежувані/змінені — повідом «ПОМИЛКА: артефакти або секрети не ігноруються» і зупинись.

## Очікувані файли
- `.gitignore` з усіма рядками зі списку вище.

## Перевірка
```bash
git rev-parse --is-inside-work-tree
for p in node_modules/ dist/ build/ coverage/ .env; do grep -qxF "$p" .gitignore || echo "бракує: $p"; done
```

## Повідомлення про помилку
- `git` не знайдено → «Git не встановлено. Встановіть Git і повторіть /git-init.»
- `.gitignore` неможливо записати → «Немає прав запису у <шлях>.»

## Заборонено
`git add`, `git commit`, `git push`, `git reset`, `git clean`, зміна `.git/config`.
