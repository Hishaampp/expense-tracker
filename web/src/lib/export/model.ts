/**
 * What an export holds: the transactions in a date range (and any filters),
 * oldest first, hidden ones left out like the app's own export, with the
 * totals the screen shows for them.
 */
import { dividedRounded, summarise, type Summary } from "@/lib/insights/money";
import type { Item, Lookup } from "@/lib/insights/tables";

export type ExportData = {
  /** "November 2026", "1 Sep – 18 Nov 2026" or "Everything". */
  label: string;
  /** For file names: "2026-11", "2026-09-01_2026-11-18" or "all". */
  slug: string;
  from: number | null;
  /** Exclusive. */
  to: number | null;
  items: Item[];
  summary: Summary;
  /** Days in the range so far (for the daily average), or null for "everything". */
  days: number | null;
  lookup: Lookup;
  monthlyBudget: number | null;
  /** Who it's for, shown on the statement. */
  email: string | null;
  generatedAt: Date;
};

export function exportData(input: Omit<ExportData, "summary" | "items"> & { items: Item[] }): ExportData {
  const items = input.items.filter((i) => !i.t.hidden).sort((a, b) => a.t.at - b.t.at || a.t.createdAt - b.t.createdAt);
  return { ...input, items, summary: summarise(items.map((i) => i.t)) };
}

export const dailyAverage = (d: ExportData) => (d.days ? dividedRounded(d.summary.spent, d.days) : null);

/** The app's kind names, and the words people read. */
export const KIND_WORDS: Record<string, string> = { expense: "Payment", income: "Money in", refund: "Refund", transfer: "Transfer" };

export const two = (n: number) => String(n).padStart(2, "0");

/** Local date and time as the app's CSV writes them. */
export function localParts(ms: number): { date: string; time: string } {
  const d = new Date(ms);
  return { date: `${d.getFullYear()}-${two(d.getMonth() + 1)}-${two(d.getDate())}`, time: `${two(d.getHours())}:${two(d.getMinutes())}` };
}

/** Paise as rupees with two decimals: "240.50". */
export function rupeesText(paise: number): string {
  const sign = paise < 0 ? "-" : "";
  const p = Math.abs(paise);
  return `${sign}${Math.trunc(p / 100)}.${two(p % 100)}`;
}

/** Hands [blob] to the browser as a download named [name]. */
export function download(blob: Blob, name: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  document.body.appendChild(a);
  a.click();
  a.remove();
  // Give the browser a moment to start the download before letting go.
  window.setTimeout(() => URL.revokeObjectURL(url), 30_000);
}
