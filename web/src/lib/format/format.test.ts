import { describe, expect, it } from "vitest";
import { formatPaise, formatPaiseCompact, formatPeriodTitle, formatPeriodRange, formatMonthShort } from "./format";

describe("formatPaise", () => {
  it("uses Indian grouping and keeps paise exact", () => {
    expect(formatPaise(12345650)).toBe("₹1,23,456.50");
    expect(formatPaise(6000)).toBe("₹60");
    expect(formatPaise(1)).toBe("₹0.01");
  });
});

describe("Overview formats", () => {
  it("compacts amounts the Indian way", () => {
    expect(formatPaiseCompact(95_000)).toBe("₹950");
    expect(formatPaiseCompact(1_250_000)).toBe("₹12.5k");
    expect(formatPaiseCompact(12_000_000)).toBe("₹1.2L");
    expect(formatPaiseCompact(-3_400_000_000)).toBe("−₹3.4Cr");
  });

  it("names months like the app", () => {
    const today = new Date(2026, 10, 19);
    expect(formatPeriodTitle({ start: new Date(2026, 10, 1), end: new Date(2026, 11, 1) }, today)).toBe("November");
    expect(formatPeriodTitle({ start: new Date(2025, 9, 25), end: new Date(2025, 10, 25) }, today)).toBe("November 2025");
    expect(formatPeriodRange({ start: new Date(2026, 9, 25), end: new Date(2026, 10, 25) })).toBe("25 Oct – 24 Nov 2026");
    expect(formatMonthShort({ start: new Date(2026, 9, 25), end: new Date(2026, 10, 25) })).toBe("Nov");
  });
});
