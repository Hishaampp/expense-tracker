import { describe, expect, it } from "vitest";
import { level } from "./spend-calendar";

describe("calendar fill", () => {
  it("keeps ordinary days visible beside one big day", () => {
    expect(level(0, 2_800_000)).toBe(0);
    expect(level(-500, 2_800_000)).toBe(0);
    expect(level(2_800_000, 2_800_000)).toBe(4);
    expect(level(250_000, 2_800_000)).toBe(2);
    expect(level(1_000, 2_800_000)).toBe(1);
  });
});
