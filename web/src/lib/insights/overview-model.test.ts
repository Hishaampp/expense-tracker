import { describe, expect, it } from "vitest";
import type { Row, Vault } from "@/lib/vault/vault";
import { overview } from "./overview";

function vault(rows: Row[], extra: Partial<Record<keyof Vault["tables"], [string, Row][]>> = {}): Vault {
  const t = (pairs: [string, Row][] = []) => new Map(pairs);
  return {
    tables: {
      accounts: t(),
      categories: t(extra.categories),
      rooms: t(extra.rooms),
      transactions: new Map(rows.map((r) => [String(r.id), r])),
      budgets: t(extra.budgets),
      payee_rules: t(),
      settings: t(extra.settings),
    },
    unreadable: 0,
    opened: rows.length,
    lastChangedAt: null,
  };
}

let n = 0;
const txn = (kind: string, paise: number, at: Date, more: Row = {}): Row => ({
  id: `t${n++}`,
  kind,
  amount_paise: paise,
  occurred_at: at.getTime(),
  is_hidden: 0,
  review_status: "confirmed",
  ...more,
});

const now = new Date(2026, 10, 19, 15, 0);

describe("overview", () => {
  const rows = [
    txn("expense", 30000, new Date(2026, 10, 3, 13), { payee_key: "swiggy", payee_display: "Swiggy", category_id: "food" }),
    txn("expense", 12000, new Date(2026, 10, 5, 20), { payee_key: "swiggy", payee_display: "Swiggy", category_id: "food" }),
    txn("refund", 2000, new Date(2026, 10, 6, 9), { payee_key: "swiggy", payee_display: "Swiggy", category_id: "food" }),
    txn("expense", 90000, new Date(2026, 10, 1, 10), { payee_key: "landlord", payee_display: "Rent", category_id: "rent" }),
    txn("income", 5000000, new Date(2026, 10, 1, 9)),
    txn("transfer", 777700, new Date(2026, 10, 2, 9)),
    txn("expense", 99999, new Date(2026, 10, 4, 9), { is_hidden: 1 }),
    txn("expense", 40000, new Date(2026, 9, 12, 9), { review_status: "needsReview" }),
  ];
  const v = vault(rows, {
    categories: [
      ["food", { id: "food", name: "Food", icon: "food" }],
      ["rent", { id: "rent", name: "Rent", icon: "rent" }],
    ],
    budgets: [
      ["m", { id: "m", category_id: null, amount_paise: 300000 }],
      ["f", { id: "f", category_id: "food", amount_paise: 30000 }],
    ],
  });
  const o = overview(v, now, 0);

  it("totals the month the app's way", () => {
    expect(o.summary.spent).toBe(130000);
    expect(o.summary.moneyIn).toBe(5000000);
    expect(o.payments).toBe(3);
    expect(o.daysCounted).toBe(19);
    expect(o.previousSummary.spent).toBe(40000);
    expect(o.needsReview).toBe(1);
    expect(o.safe).toEqual({ kind: "onTrack", budget: 300000, spent: 130000, left: 170000, daysLeft: 12, perDay: 14166 });
  });

  it("ranks categories with their budgets", () => {
    expect(o.categories.map((c) => [c.name, c.spent, c.budget])).toEqual([
      ["Rent", 90000, null],
      ["Food", 40000, 30000],
    ]);
  });

  it("totals payees: refunds reduce, only payments are counted", () => {
    expect(o.payees[0]).toEqual({ key: "landlord", name: "Rent", spent: 90000, payments: 1, average: 90000 });
    expect(o.payees[1]).toEqual({ key: "swiggy", name: "Swiggy", spent: 40000, payments: 2, average: 20000 });
  });

  it("builds 12 trend months ending at the shown one, and every day of it", () => {
    expect(o.trend).toHaveLength(12);
    expect(o.trend.at(-1)).toMatchObject({ spent: 130000, moneyIn: 5000000, isShown: true });
    expect(o.trend.at(-2)!.spent).toBe(40000);
    expect(o.days).toHaveLength(30);
    expect(o.days[2].spent).toBe(30000);
    expect(o.days[5].spent).toBe(-2000);
    expect(o.days[18].future).toBe(false);
    expect(o.days[19].future).toBe(true);
  });

  it("follows the synced month start day", () => {
    const shifted = overview(vault(rows, { settings: [["month_start_day", { key: "month_start_day", value: "25" }]] }), now, 0);
    expect(shifted.period.start).toEqual(new Date(2026, 9, 25));
    expect(shifted.summary.spent).toBe(130000);
  });

  it("an earlier month has no safe-to-spend", () => {
    expect(overview(v, now, -1).safe).toEqual({ kind: "none" });
  });
});
