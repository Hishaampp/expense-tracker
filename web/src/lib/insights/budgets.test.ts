import { describe, expect, it } from "vitest";
import type { Row, Vault } from "@/lib/vault/vault";
import { budgetsOf } from "./budgets";
import { transactionsOf } from "./overview";

const tables = (rows: Partial<Record<keyof Vault["tables"], [string, Row][]>>): Vault => ({
  tables: {
    accounts: new Map(),
    categories: new Map(),
    rooms: new Map(rows.rooms),
    transactions: new Map(rows.transactions),
    budgets: new Map(rows.budgets),
    payee_rules: new Map(),
    settings: new Map(),
  },
  unreadable: 0,
  opened: 0,
  lastChangedAt: null,
});
const tx = (id: string, paise: number, at: Date, more: Row = {}): [string, Row] => [id, { id, kind: "expense", amount_paise: paise, occurred_at: at.getTime(), is_hidden: 0, ...more }];

describe("budgets", () => {
  const v = tables({
    budgets: [
      ["m", { category_id: null, amount_paise: 100000 }],
      ["f", { category_id: "food", amount_paise: 20000 }],
    ],
    rooms: [["goa", { id: "goa", counts_toward_monthly_budget: 0 }]],
    transactions: [
      tx("a", 30000, new Date(2026, 10, 2), { category_id: "food" }),
      tx("b", 50000, new Date(2026, 10, 3), { category_id: "food", room_id: "goa" }),
      tx("c", 40000, new Date(2026, 9, 9), { category_id: "food" }),
    ],
  });
  const b = budgetsOf(v, transactionsOf(v), new Date(2026, 10, 19));

  it("leaves Rooms outside the budget out, like the app", () => {
    expect(b.monthly).toBe(100000);
    expect(b.months.at(-1)!.monthly).toBe(30000);
    expect(b.months.at(-1)!.byCategory.get("food")).toBe(30000);
    expect(b.safe).toEqual({ kind: "onTrack", budget: 100000, spent: 30000, left: 70000, daysLeft: 12, perDay: 5833 });
  });

  it("keeps 6 months, oldest first", () => {
    expect(b.months).toHaveLength(6);
    expect(b.months.at(-2)!.monthly).toBe(40000);
  });
});
