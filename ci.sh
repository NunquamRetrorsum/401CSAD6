#!/usr/bin/env bash
# Локальний і CI-скрипт складання для Linux/macOS.
# Єдине джерело правди для кроків: встановлення, перевірка типів, складання,
# юніт-тести, smoke-тест виконуваного файлу. GitHub Actions лише викликає цей скрипт.
set -euo pipefail

cd "$(dirname "$0")"

step() { printf '\n==> %s\n' "$1"; }

step "Версії інструментів"
node --version
npm --version

step "Встановлення залежностей (npm ci)"
npm ci

step "Перевірка типів"
npm run typecheck

step "Складання (tsc + postbuild)"
npm run build

step "Юніт-тести (vitest)"
npm test

step "Smoke-тест виконуваного файлу dist/hello"
output="$(./dist/hello)"
echo "$output"
if [ "$output" != "Hello, World!" ]; then
  echo "ПОМИЛКА: очікувалось 'Hello, World!', отримано '$output'" >&2
  exit 1
fi

step "Готово: складання, тести та smoke-тест пройшли успішно"
