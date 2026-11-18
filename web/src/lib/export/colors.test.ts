import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { categoryColor } from "./colors";

describe("PDF category colours", () => {
  it("are the same as the website's --cat-* tokens", () => {
    const css = readFileSync("src/app/globals.css", "utf8");
    const token = (name: string) => css.match(new RegExp(`--cat-${name}: #([0-9a-f]{6})`))![1];
    const hex = (rgb: number[]) => rgb.map((v) => v.toString(16).padStart(2, "0")).join("");
    expect(hex(categoryColor("food"))).toBe(token("orange"));
    expect(hex(categoryColor("rent"))).toBe(token("violet"));
    expect(hex(categoryColor("unknown-key"))).toBe(token("grey"));
    expect(hex(categoryColor(null))).toBe(token("grey"));
  });
});
