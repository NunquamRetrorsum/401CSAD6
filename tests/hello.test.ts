import { describe, expect, it } from "vitest";
import { add, greet } from "../src/lib.js";

describe("hello-world-ts", () => {
  it("BasicAddition", () => {
    expect(add(2, 3)).toBe(5);
    expect(add(-1, 1)).toBe(0);
    expect(add(0.1, 0.2)).toBeCloseTo(0.3);
  });

  it("greets the world by default", () => {
    expect(greet()).toBe("Hello, World!");
  });

  it("greets a given name", () => {
    expect(greet("APKS")).toBe("Hello, APKS!");
  });
});
