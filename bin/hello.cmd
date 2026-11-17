@echo off
rem Обгортка для Windows: запускає зібраний dist\hello.js через Node.js
node "%~dp0hello.js" %*
