import { describe, expect, it } from "vitest";
import { monthlyAverage, payeesOf, totalsFor } from "./browse";
import type { Txn } from "./money";

const base: Txn = { id: "", kind: "expense", paise: 0, at: 0, categoryId: null, roomId: null, payeeKey: null, payeeDisplay: null, hidden: false, needsReview: false, accountId: null, toAccountId: null, note: null, origin: "manual", instrument: null, refNo: null, linkedId: null, createdAt: 0 };
const t = (p: Partial<Txn>): Txn => ({ ...base, ...p });
const months = [0, 1, 2].map((m) => ({ start: new Date(2026, 8 + m, 1), end: new Date(2026, 9 + m, 1), startDay: 1 }));

describe("browse totals", () => {
  const txns = [
    t({ id: "a", paise: 10000, at: new Date(2026, 8, 5).getTime(), payeeKey: "swiggy", payeeDisplay: "Swiggy", categoryId: "food" }),
    t({ id: "b", kind: "refund", paise: 2000, at: new Date(2026, 8, 6).getTime(), payeeKey: "swiggy", categoryId: "food" }),
    t({ id: "c", paise: 30000, at: new Date(2026, 10, 2).getTime(), payeeKey: "swiggy", payeeDisplay: "Swiggy Instamart", categoryId: "groceries" }),
    t({ id: "d", paise: 99999, at: new Date(2026, 10, 3).getTime(), payeeKey: "swiggy", hidden: true }),
    t({ id: "e", kind: "transfer", paise: 50000, at: new Date(2026, 10, 3).getTime(), payeeKey: "swiggy" }),
  ];

  it("sums months the app's way", () => {
    const s = totalsFor(txns, months, (x) => x.payeeKey === "swiggy");
    expect(s.monthly).toEqual([8000, 0, 30000]);
    expect(s.spent).toBe(38000);
    expect(s.payments).toBe(2);
    expect(monthlyAverage(s.monthly)).toBe(19000);
  });

  it("names a payee by its latest name and category", () => {
    expect(payeesOf(txns).get("swiggy")).toMatchObject({ name: "Swiggy Instamart", categoryId: "groceries" });
  });
});
