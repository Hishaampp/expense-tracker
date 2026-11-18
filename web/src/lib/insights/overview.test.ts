import { describe, expect, it } from "vitest";
import vectors from "./fixtures/overview-vectors.json";
import { carriedInto, dividedRounded, firstIncomeAt, inPeriod, safeToSpend, summarise, type Txn } from "./money";
import { daysElapsedOn, daysLeftIncluding, periodContaining, shifted } from "./period";

// Computed by the app's own Dart code: test/core/web_overview_vectors_test.dart.
const txns: Txn[] = vectors.transactions.map((t) => {
  const [y, mo, d, h, mi] = t.at;
  return {
    id: t.id,
    kind: t.kind as Txn["kind"],
    paise: t.paise,
    at: new Date(y, mo - 1, d, h, mi).getTime(),
    categoryId: t.categoryId,
    roomId: t.roomId,
    payeeKey: null,
    payeeDisplay: null,
    hidden: t.hidden,
    needsReview: false,
  };
});
const day = (s: string) => {
  const [y, m, d] = s.split("-").map(Number);
  return new Date(y, m - 1, d);
};
const iso = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
const budgetRooms = new Set(vectors.budgetRooms);

describe("the Overview matches the app's maths", () => {
  for (const c of vectors.cases) {
    it(`start day ${c.startDay}, today ${c.today}, ${c.offset} months`, () => {
      const today = day(c.today);
      const period = shifted(periodContaining(today, c.startDay), c.offset);
      expect([iso(period.start), iso(period.end)]).toEqual([c.start, c.end]);
      expect(daysElapsedOn(period, today)).toBe(c.daysElapsed);
      expect(daysLeftIncluding(period, today)).toBe(c.daysLeft);

      const s = summarise(inPeriod(txns, period), budgetRooms);
      expect(s.spent).toBe(c.summary.spent);
      expect(s.spentInRooms).toBe(c.summary.spentInRooms);
      expect(s.spentForBudget).toBe(c.summary.spentForBudget);
      expect(s.moneyIn).toBe(c.summary.moneyIn);
      expect(s.byCategory.map((x) => [x.categoryId, x.spent])).toEqual(c.summary.byCategory);
      expect(Object.fromEntries(s.budgetByCategory)).toEqual(c.summary.budgetByCategory);
      expect(dividedRounded(s.spent, daysElapsedOn(period, today))).toBe(c.dailyAverage);

      const first = firstIncomeAt(txns)!;
      const balanceStart = periodContaining(new Date(first), c.startDay).start.getTime();
      expect(carriedInto(txns, period, balanceStart)).toBe(c.carried);

      const safe = safeToSpend(c.offset === 0 ? vectors.monthlyBudget : null, s.spentForBudget, period, today);
      const { kind } = safe;
      const shape =
        safe.kind === "onTrack"
          ? { kind, left: safe.left, daysLeft: safe.daysLeft, perDay: safe.perDay }
          : safe.kind === "over"
            ? { kind, over: safe.over }
            : { kind };
      expect(shape).toEqual(c.safe);
    });
  }

  it("rounds half away from zero, like Money.dividedRounded", () => {
    expect(dividedRounded(5, 2)).toBe(3);
    expect(dividedRounded(-5, 2)).toBe(-3);
    expect(dividedRounded(4, 3)).toBe(1);
    expect(dividedRounded(100, 0)).toBe(0);
  });
});
