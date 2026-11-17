/**
 * Бібліотечна частина проєкту Hello World.
 * Функції винесені окремо від точки входу, щоб їх можна було
 * імпортувати в юніт-тестах без побічних ефектів (виводу в консоль).
 */

/** Повертає привітання для вказаного імені. */
export function greet(name = "World"): string {
  return `Hello, ${name}!`;
}

/** Додає два числа. Використовується тестом BasicAddition. */
export function add(a: number, b: number): number {
  return a + b;
}
