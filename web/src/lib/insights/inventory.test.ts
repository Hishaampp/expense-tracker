import { describe, expect, it } from "vitest";
import type { Row, Vault } from "@/lib/vault/vault";
import { inventory } from "./inventory";

function vault(transactions: Row[]): Vault {
  const map = (rows: Row[]) => new Map(rows.map((r, i) => [String(i), r]));
  return {
    tables: {
      accounts: map([{ is_archived: 0 }, { is_archived: 1 }]),
      categories: map([{ is_archived: 0 }]),
      rooms: map([]),
      transactions: map(transactions),
      budgets: map([]),
      payee_rules: map([]),
      settings: map([]),
    },
    unreadable: 0,
    opened: 0,
    lastChangedAt: null,
  };
}

describe("inventory", () => {
  it("counts by kind and finds the date range", () => {
    const inv = inventory(
      vault([
        { kind: "expense", review_status: "confirmed", is_hidden: 0, occurred_at: 300 },
        { kind: "expense", review_status: "needs_review", is_hidden: 0, occurred_at: 100 },
        { kind: "income", review_status: "confirmed", is_hidden: 0, occurred_at: 200 },
        { kind: "transfer", review_status: "pending", is_hidden: 1, occurred_at: 250 },
      ]),
    );
    expect(inv).toMatchObject({ payments: 2, moneyIn: 1, transfers: 1, needsReview: 1, accounts: 1, firstAt: 100, lastAt: 300 });
  });
});
