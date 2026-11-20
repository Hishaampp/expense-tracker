import { describe, expect, it } from "vitest";
import type { Vault } from "@/lib/vault/vault";
import { scopeOf } from "./scope";

const vault = (startDay?: string): Vault => ({
  tables: {
    accounts: new Map(),
    categories: new Map(),
    rooms: new Map(),
    transactions: new Map(),
    budgets: new Map(),
    payee_rules: new Map(),
    settings: new Map(startDay ? [["month_start_day", { key: "month_start_day", value: startDay }]] : []),
  },
  unreadable: 0,
  opened: 0,
  lastChangedAt: null,
});
const now = new Date(2026, 10, 18, 15);
const none = { from: "", to: "" };

describe("export scope", () => {
  it("names a month like the app, with the days so far", () => {
    expect(scopeOf("this", vault(), now, none)).toMatchObject({ label: "November 2026", slug: "2026-11", days: 18 });
    expect(scopeOf("last", vault(), now, none)).toMatchObject({ label: "October 2026", slug: "2026-10", days: 31 });
    expect(scopeOf("this", vault("25"), now, none)).toMatchObject({ label: "25 Oct – 24 Nov 2026", slug: "2026-10", days: 25 });
  });

  it("names other ranges by their dates", () => {
    expect(scopeOf("all", vault(), now, none)).toMatchObject({ label: "Everything", slug: "all", days: null });
    const custom = scopeOf("custom", vault(), now, { from: "2026-09-01", to: "2026-09-30" });
    expect(custom).toMatchObject({ label: "1 Sept 2026 – 30 Sept 2026", slug: "2026-09-01_2026-09-30", days: 30 });
  });
});
