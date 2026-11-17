#!/usr/bin/env node
/**
 * Точка входу виконуваного файлу `hello`.
 * Після складання: dist/hello.js (запускається Node.js),
 * а також обгортки dist/hello (sh) та dist/hello.cmd (Windows).
 */
import { greet } from "./lib.js";

const name = process.argv[2];
console.log(greet(name));
