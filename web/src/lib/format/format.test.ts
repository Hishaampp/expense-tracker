import { describe, expect, it } from "vitest";
import { formatPaise } from "./format";

describe("formatPaise", () => {
  it("uses Indian grouping and keeps paise exact", () => {
    expect(formatPaise(12345650)).toBe("₹1,23,456.50");
    expect(formatPaise(6000)).toBe("₹60");
    expect(formatPaise(1)).toBe("₹0.01");
  });
});
