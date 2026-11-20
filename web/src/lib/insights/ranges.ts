import { periodContaining, shifted, startDayFrom } from "./period";
import type { Vault } from "@/lib/vault/vault";

export type RangeKey = "all" | "this" | "last" | "3m" | "year" | "custom";

/** "2026-11-03" to local midnight, or null. */
export function dayFromIso(text: string | null | undefined): number | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(text ?? "");
  if (!m) return null;
  return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3])).getTime();
}

/** Local midnight to "2026-11-03". */
export function isoOfDay(ms: number): string {
  const d = new Date(ms);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

/**
 * The from/to bounds (local midnights, end exclusive) of a range, in
 * budgeting months that follow the synced month start day. A custom range
 * includes its last day.
 */
export function rangeBounds(key: RangeKey, vault: Vault, now: Date, customFrom: string | null, customTo: string | null): { from: number | null; to: number | null } {
  const current = periodContaining(new Date(now.getFullYear(), now.getMonth(), now.getDate()), startDayFrom(vault.tables.settings));
  switch (key) {
    case "this":
      return { from: current.start.getTime(), to: current.end.getTime() };
    case "last": {
      const p = shifted(current, -1);
      return { from: p.start.getTime(), to: p.end.getTime() };
    }
    case "3m":
      return { from: shifted(current, -2).start.getTime(), to: current.end.getTime() };
    case "year":
      return { from: shifted(current, -11).start.getTime(), to: current.end.getTime() };
    case "custom": {
      const from = dayFromIso(customFrom);
      const last = dayFromIso(customTo);
      const to = last === null ? null : new Date(new Date(last).getFullYear(), new Date(last).getMonth(), new Date(last).getDate() + 1).getTime();
      return { from, to };
    }
    default:
      return { from: null, to: null };
  }
}
