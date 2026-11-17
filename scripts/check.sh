#!/usr/bin/env bash
# Реалізація команди /check: 11 перевірок без змін у проєкті.
# Повертає 0, якщо всі PASS, інакше 1. Використовується агентом і вручну.
cd "$(dirname "$0")/.."
export LC_ALL=${LC_ALL:-en_US.UTF-8}
pass=0; fail=0; report=()

run() { # run <номер> <назва> <команда...>
  local n="$1" name="$2"; shift 2
  local out
  local dots; dots=$(printf '%*s' $((26 - ${#name})) '' | tr ' ' '.')
  if out=$("$@" 2>&1); then
    pass=$((pass+1)); report+=("$(printf ' %2s. %s %s PASS' "$n" "$name" "$dots")")
  else
    fail=$((fail+1)); report+=("$(printf ' %2s. %s %s FAIL  (%s)' "$n" "$name" "$dots" "$(echo "$out" | grep -v '^$' | tail -1 | cut -c1-90)")")
  fi
}

c1() { f=.github/agents/build-engineer.agent.md; test -f $f && grep -q '## Роль' $f && grep -q '## Заборонені дії' $f && grep -q '## Критерії успішного завершення' $f; }
c2() { for s in project-scaffold build-and-test github-actions; do f=.github/skills/$s/SKILL.md; test -f $f && grep -q 'Вхідні дані' $f && grep -q 'Результат' $f && grep -q 'Перевірки' $f || { echo "skill $s неповний"; return 1; }; done; }
c3() { for p in git-init create-project create-build create-actions check init-all; do test -f .github/prompts/$p.prompt.md || { echo "бракує $p.prompt.md"; return 1; }; done; }
c4() { for f in src/hello.ts src/lib.ts tests/hello.test.ts README.md docs/architecture.md docs/usage.md .gitignore; do test -f $f || { echo "бракує $f"; return 1; }; done; }
c5() { node -e 'const p=require("./package.json");if(!p.scripts.build||!p.scripts.test)process.exit(1)' && grep -q '"types": \["node"\]' tsconfig.json; }
c6() { npm run build >/dev/null && test -f dist/hello.js && test -f dist/hello && test -f dist/hello.cmd; }
c7() { out=$(npm test 2>&1) && echo "$out" | grep -q 'BasicAddition\|passed' || { echo "$out" | grep -E 'FAIL|expected|✗|×' | head -2; return 1; }; }
c8() { out=$(./dist/hello); [ "$out" = "Hello, World!" ] || { echo "отримано '$out'"; return 1; }; }
c9() { test -f ci.sh && test -f ci.bat && ./ci.sh >/dev/null; }
c10() { f=.github/workflows/ci.yml; grep -q ubuntu-latest $f && grep -q windows-latest $f && grep -q macos-latest $f && grep -q 'ci.sh' $f && grep -q 'ci.bat' $f && ! grep -q 'secrets\.' $f; }
c11() { ! git status --porcelain 2>/dev/null | grep -qE '(^|/)(dist|node_modules|coverage)/|\.env'; }

run 1  "Маніфест агента"   c1
run 2  "Skills"            c2
run 3  "Commands"          c3
run 4  "Структура"         c4
run 5  "Конфігурація"      c5
run 6  "Складання"         c6
run 7  "Тести"             c7
run 8  "Виконуваний файл"  c8
run 9  "CI-скрипти"        c9
run 10 "Workflow"          c10
run 11 "Git"               c11

echo "/check — звіт"
printf '%s\n' "${report[@]}"
if [ "$fail" -eq 0 ]; then
  echo "Підсумок: $pass/11 PASS. Проєкт готовий."
else
  echo "Підсумок: $pass/11 PASS. Проєкт НЕ ГОТОВИЙ. Виправте пункти з FAIL."
  exit 1
fi
