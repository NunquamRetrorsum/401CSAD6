@echo off
rem Локальний і CI-скрипт складання для Windows.
rem Дзеркало ci.sh: встановлення, перевірка типів, складання, тести, smoke-тест.
setlocal
cd /d "%~dp0"

echo.
echo ==^> Версії інструментів
call node --version || goto :fail
call npm --version || goto :fail

echo.
echo ==^> Встановлення залежностей (npm ci)
call npm ci || goto :fail

echo.
echo ==^> Перевірка типів
call npm run typecheck || goto :fail

echo.
echo ==^> Складання (tsc + postbuild)
call npm run build || goto :fail

echo.
echo ==^> Юніт-тести (vitest)
call npm test || goto :fail

echo.
echo ==^> Smoke-тест виконуваного файлу dist\hello.cmd
for /f "usebackq delims=" %%i in (`call dist\hello.cmd`) do set "OUTPUT=%%i"
echo %OUTPUT%
if not "%OUTPUT%"=="Hello, World!" (
  echo ПОМИЛКА: очікувалось "Hello, World!", отримано "%OUTPUT%" 1>&2
  goto :fail
)

echo.
echo ==^> Готово: складання, тести та smoke-тест пройшли успішно
endlocal
exit /b 0

:fail
echo.
echo ==^> ПОМИЛКА: крок завершився з кодом %errorlevel% 1>&2
endlocal
exit /b 1
