/**
 * The transactions as CSV, byte for byte the app's own export
 * (lib/data/backup/csv_export.dart): rupees with two decimals, the phone's
 * local time, hidden ones left out, and text a spreadsheet would run as a
 * formula defused with a leading apostrophe.
 */
import type { Item } from "@/lib/insights/tables";
import { localParts, rupeesText } from "./model";

const HEADER = ["Date", "Time", "Type", "Amount (INR)", "Category", "Account", "Room", "Payee", "Note", "Status", "Source"];

/** Quotes a cell when needed, and defuses a would-be formula ("=HYPERLINK(...)"). */
export function csvCell(value: string): string {
  const safe = /^[=+\-@\t\r]/.test(value) ? `'${value}` : value;
  if (!/[",\r\n]/.test(safe)) return safe;
  return `"${safe.replace(/"/g, '""')}"`;
}

export function transactionsCsv(items: readonly Item[]): string {
  const lines: string[][] = [HEADER];
  for (const { t, category, account, room } of items) {
    if (t.hidden) continue;
    const { date, time } = localParts(t.at);
    lines.push([
      date,
      time,
      t.kind,
      // The app writes paise ~/ 100 and paise % 100; amounts are never negative.
      rupeesText(t.paise),
      category?.name ?? "",
      account?.name ?? "",
      room?.name ?? "",
      t.payeeDisplay ?? "",
      t.note ?? "",
      t.needsReview ? "needsReview" : "confirmed",
      t.origin,
    ]);
  }
  return `${lines.map((l) => l.map(csvCell).join(",")).join("\r\n")}\r\n`;
}
