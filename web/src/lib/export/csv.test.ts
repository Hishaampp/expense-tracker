import { describe, expect, it } from "vitest";
import type { Txn } from "@/lib/insights/money";
import { itemsOf, type Lookup } from "@/lib/insights/tables";
import { transactionsCsv } from "./csv";
import vectors from "./fixtures/csv-vectors.json";

// Written by the app's own Dart code: test/data/backup/web_csv_vectors_test.dart.
describe("CSV", () => {
  it("is byte for byte the app's export", () => {
    const txns: Txn[] = vectors.transactions.map((c) => {
      const [y, mo, d, h, mi] = c.at;
      const at = new Date(y, mo - 1, d, h, mi).getTime();
      return {
        id: c.id,
        kind: c.kind as Txn["kind"],
        paise: c.paise,
        at,
        categoryId: c.categoryId ?? null,
        roomId: c.roomId ?? null,
        payeeKey: null,
        payeeDisplay: c.payee ?? null,
        hidden: c.hidden === true,
        needsReview: c.review === "needsReview",
        accountId: c.accountId,
        toAccountId: null,
        note: c.note ?? null,
        origin: c.origin ?? "manual",
        instrument: null,
        refNo: null,
        linkedId: null,
        createdAt: at,
      };
    });
    const lookup: Lookup = {
      categories: new Map(vectors.categories.map((c) => [c.id, { ...c, icon: null, kind: "expense", archived: false }])),
      accounts: new Map(vectors.accounts.map((a) => [a.id, { ...a, archived: false }])),
      rooms: new Map(vectors.rooms.map((r) => [r.id, { ...r, emoji: null, type: "trip", startDay: null, endDay: null, budget: null, countsTowardBudget: false, archived: false }])),
    };
    expect(transactionsCsv(itemsOf(txns, lookup))).toBe(vectors.csv);
  });
});
