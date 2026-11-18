import { describe, expect, it } from "vitest";
import vectors from "./fixtures/tables-vectors.json";
import type { Txn } from "./money";
import { itemsOf, localDay, matches, NO_FILTER, roomSummary, type Filter, type Lookup } from "./tables";

// Written by the app's own Dart code: test/core/web_tables_vectors_test.dart.
const txns: Txn[] = vectors.transactions.map((t) => {
  const [y, mo, d, h, mi] = t.at;
  const at = new Date(y, mo - 1, d, h, mi).getTime();
  return {
    id: t.id,
    kind: t.kind as Txn["kind"],
    paise: t.paise,
    at,
    categoryId: t.categoryId,
    roomId: t.roomId,
    payeeKey: t.payeeKey,
    payeeDisplay: t.payeeDisplay,
    hidden: t.hidden,
    needsReview: false,
    accountId: t.accountId,
    toAccountId: null,
    note: t.note,
    origin: t.origin,
    instrument: null,
    refNo: null,
    linkedId: null,
    createdAt: at,
  };
});
const lookup: Lookup = {
  categories: new Map(vectors.categories.map((c) => [c.id, { ...c, icon: null, kind: "expense", archived: false }])),
  accounts: new Map(vectors.accounts.map((a) => [a.id, { ...a, archived: false }])),
  rooms: new Map(),
};
const visible = itemsOf(txns.filter((t) => !t.hidden), lookup);

describe("search and filters match the app's Activity", () => {
  for (const c of vectors.filters) {
    it(c.name, () => {
      const f: Filter = { ...NO_FILTER, query: c.query, categoryId: c.categoryId, roomId: c.roomId, accountId: c.accountId, kind: c.kind as Filter["kind"], origin: c.origin };
      expect(visible.filter((i) => matches(i, f)).map((i) => i.t.id)).toEqual(c.ids);
    });
  }
});

describe("Room totals match the app", () => {
  const [ty, tm, td] = vectors.today;
  const today = localDay(new Date(ty, tm - 1, td).getTime());
  const iso = (day: number) => {
    const u = new Date(day * 86_400_000);
    return `${u.getUTCFullYear()}-${String(u.getUTCMonth() + 1).padStart(2, "0")}-${String(u.getUTCDate()).padStart(2, "0")}`;
  };
  for (const r of vectors.rooms) {
    it(r.id, () => {
      const room = { id: r.id, name: r.id, emoji: null, type: "trip", startDay: r.startDay, endDay: r.endDay, budget: r.budget, countsTowardBudget: false, archived: false };
      const s = roomSummary(room, txns.filter((t) => t.roomId === r.id), today);
      expect(s.spent).toBe(r.spent);
      expect(s.byCategory.map((c) => [c.categoryId, c.spent])).toEqual(r.byCategory);
      expect(s.byDay.map((d) => [iso(d.day), d.spent])).toEqual(r.byDay);
      expect(s.days).toBe(r.days);
      expect(s.perDay).toBe(r.perDay);
      expect(s.remaining).toBe(r.remaining);
    });
  }
});
