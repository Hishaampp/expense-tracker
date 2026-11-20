/**
 * Which records an export covers: a date range in budgeting months, plus
 * any filters carried over from Transactions.
 */
import { formatDate, formatPeriodRange } from "@/lib/format/format";
import { periodContaining, shifted, startDayFrom } from "@/lib/insights/period";
import { isoOfDay, rangeBounds, type RangeKey } from "@/lib/insights/ranges";
import { filterCount, matches, NO_FILTER, type Filter, type Item } from "@/lib/insights/tables";
import type { Vault } from "@/lib/vault/vault";

const DAY = 86_400_000;

export type Scope = { label: string; slug: string; from: number | null; to: number | null; days: number | null };

export function scopeOf(range: RangeKey, vault: Vault, now: Date, custom: { from: string; to: string }): Scope {
  const { from, to } = rangeBounds(range, vault, now, custom.from, custom.to);
  const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).getTime();
  // Days so far, for the daily average: up to today for a range still running.
  const days = from === null ? null : Math.max(1, Math.round((Math.min(to ?? todayEnd, todayEnd) - from) / DAY));
  if (range === "this" || range === "last") {
    const current = periodContaining(new Date(now.getFullYear(), now.getMonth(), now.getDate()), startDayFrom(vault.tables.settings));
    const p = range === "this" ? current : shifted(current, -1);
    return { label: formatPeriodRange(p), slug: isoOfDay(p.start.getTime()).slice(0, 7), from, to, days };
  }
  if (from === null && to === null) return { label: "Everything", slug: "all", from, to, days: null };
  const lastDay = to === null ? null : to - DAY;
  const label = `${from === null ? "Up to" : formatDate(from)}${lastDay === null ? " onwards" : `${from === null ? " " : " – "}${formatDate(lastDay)}`}`;
  const slug = `${from === null ? "start" : isoOfDay(from)}_${lastDay === null ? "now" : isoOfDay(lastDay)}`;
  return { label, slug, from, to, days };
}

/** The transactions in [scope] passing [filter] (the date range comes from the scope). */
export function itemsIn(items: readonly Item[], scope: Scope, filter: Filter): Item[] {
  const f = { ...filter, from: scope.from, to: scope.to };
  return items.filter((i) => !i.t.hidden && matches(i, f));
}

/** Filters from Transactions in the address, without its date range (the Export page sets that). */
export function filterFromParams(p: URLSearchParams): Filter {
  const kind = p.get("kind");
  return {
    ...NO_FILTER,
    query: p.get("q") ?? "",
    categoryId: p.get("category"),
    accountId: p.get("account"),
    roomId: p.get("room"),
    kind: kind === "expense" || kind === "income" || kind === "refund" || kind === "transfer" ? kind : null,
    origin: p.get("origin"),
    needsReview: p.get("review") === "1",
  };
}

export const hasFilters = (f: Filter) => f.query.trim() !== "" || filterCount(f) > 0;
