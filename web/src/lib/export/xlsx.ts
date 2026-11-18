/**
 * The Excel workbook: Summary, Transactions, Categories, Payees and Rooms.
 * Amounts are real numbers shown as ₹; every total is a live formula over
 * the Transactions sheet (with its value already worked out, for previews
 * that don't calculate); headers are frozen and filters are on.
 */
import type ExcelJS from "exceljs";
import { summarise } from "@/lib/insights/money";
import { payeeKeyOf, type Item } from "@/lib/insights/tables";
import { KIND_WORDS, localParts, type ExportData } from "./model";

const INR = '"₹"#,##0.00';
const HONEY = "FFF2B33D";
const INK = "FF121212";
const MUTED = "FF616161";

type Sheet = ExcelJS.Worksheet;

function header(sheet: Sheet, titles: string[], widths: number[]) {
  sheet.columns = titles.map((t, i) => ({ header: t, width: widths[i] }));
  const row = sheet.getRow(1);
  row.font = { bold: true, color: { argb: INK } };
  row.fill = { type: "pattern", pattern: "solid", fgColor: { argb: HONEY } };
  row.alignment = { vertical: "middle" };
  row.height = 22;
  sheet.views = [{ state: "frozen", ySplit: 1 }];
}

/** Filters on every column of a list sheet. */
function filters(sheet: Sheet) {
  sheet.autoFilter = { from: { row: 1, column: 1 }, to: { row: Math.max(2, sheet.rowCount), column: sheet.columnCount } };
}

/** A1-style column letter for a 1-based index. */
const col = (n: number) => String.fromCharCode(64 + n);

// Transactions sheet layout: the formulas below refer to these columns.
export const T = { date: 1, time: 2, type: 3, amount: 4, category: 5, account: 6, toAccount: 7, room: 8, payee: 9, note: 10, status: 11, source: 12 };

const rupees = (paise: number) => paise / 100;

/** Builds the workbook. [Excel] is the exceljs module (loaded on demand in the browser). */
export function buildWorkbook(Excel: typeof ExcelJS, d: ExportData): ExcelJS.Workbook {
  const wb = new Excel.Workbook();
  wb.creator = "Ample";
  wb.created = d.generatedAt;
  const summary = wb.addWorksheet("Summary", { properties: { tabColor: { argb: HONEY } } });
  const tx = wb.addWorksheet("Transactions");
  const cats = wb.addWorksheet("Categories");
  const payees = wb.addWorksheet("Payees");
  const rooms = wb.addWorksheet("Rooms");

  // Transactions.
  header(tx, ["Date", "Time", "Type", "Amount", "Category", "Account", "To account", "Room", "Payee", "Note", "Status", "Recorded"], [12, 8, 11, 14, 18, 18, 16, 16, 26, 30, 14, 11]);
  for (const { t, category, account, toAccount, room } of d.items) {
    const day = new Date(t.at);
    tx.addRow([
      // The local calendar day as a UTC date, so every time zone shows the phone's date.
      new Date(Date.UTC(day.getFullYear(), day.getMonth(), day.getDate())),
      localParts(t.at).time,
      KIND_WORDS[t.kind],
      rupees(t.paise),
      category?.name ?? "",
      account?.name ?? "",
      toAccount?.name ?? "",
      room?.name ?? "",
      t.payeeDisplay ?? t.payeeKey ?? "",
      t.note ?? "",
      t.needsReview ? "Needs review" : "Confirmed",
      t.origin === "auto" ? "Captured" : "Typed in",
    ]);
  }
  tx.getColumn(T.date).numFmt = "dd mmm yyyy";
  tx.getColumn(T.amount).numFmt = INR;
  filters(tx);
  const last = Math.max(2, d.items.length + 1);
  const range = (c: number) => `Transactions!$${col(c)}$2:$${col(c)}$${last}`;
  const amounts = range(T.amount);
  const types = range(T.type);
  /** Payments minus refunds where column [c] equals [ref]. */
  const spentWhere = (c: number, ref: string) =>
    `SUMIFS(${amounts},${types},"Payment",${range(c)},${ref})-SUMIFS(${amounts},${types},"Refund",${range(c)},${ref})`;

  // Summary.
  summary.columns = [{ width: 30 }, { width: 22 }];
  summary.getCell("A1").value = "Ample";
  summary.getCell("A1").font = { bold: true, size: 20, color: { argb: INK } };
  summary.getCell("A2").value = d.label;
  summary.getCell("A2").font = { size: 13, color: { argb: MUTED } };
  const s = d.summary;
  const payments = d.items.filter((i) => i.t.kind === "expense").length;
  const rows: [string, ExcelJS.CellValue, string?][] = [
    ["Spent", { formula: `SUMIFS(${amounts},${types},"Payment")-SUMIFS(${amounts},${types},"Refund")`, result: rupees(s.spent) }, INR],
    ["Money in", { formula: `SUMIFS(${amounts},${types},"Money in")`, result: rupees(s.moneyIn) }, INR],
    ["Kept (money in − spent)", { formula: "B5-B4", result: rupees(s.moneyIn - s.spent) }, INR],
    ["Payments", { formula: `COUNTIFS(${types},"Payment")`, result: payments }],
    ["Transactions", { formula: `COUNTA(${types})`, result: d.items.length }],
  ];
  if (d.days) rows.push(["Daily average", { formula: `ROUND(B4/${d.days},2)`, result: Math.round(s.spent / d.days) / 100 }, INR]);
  rows.forEach(([label, value, fmt], i) => {
    const r = summary.getRow(4 + i);
    r.getCell(1).value = label;
    r.getCell(2).value = value;
    if (fmt) r.getCell(2).numFmt = fmt;
    r.getCell(2).font = { bold: true };
  });
  const note = summary.getRow(5 + rows.length);
  note.getCell(1).value =
    "Made by Ample in your browser. Hidden transactions are left out, refunds reduce spending, and transfers count as neither. The totals are formulas: they update if you change the Transactions sheet.";
  note.getCell(1).alignment = { wrapText: true, vertical: "top" };
  note.getCell(1).font = { color: { argb: MUTED } };
  summary.mergeCells(`A${note.number}:B${note.number}`);
  note.height = 64;

  // Categories that had spending, largest first.
  header(cats, ["Category", "Spent", "Payments", "Share of spending"], [24, 16, 11, 18]);
  s.byCategory.forEach((c, i) => {
    const name = c.categoryId ? (d.lookup.categories.get(c.categoryId)?.name ?? "") : "";
    const r = i + 2;
    // Uncategorised rows have an empty Category cell on the Transactions sheet.
    const ref = name ? `A${r}` : '""';
    cats.addRow([
      name || "Uncategorised",
      { formula: spentWhere(T.category, ref), result: rupees(c.spent) },
      { formula: `COUNTIFS(${types},"Payment",${range(T.category)},${ref})`, result: d.items.filter((it) => it.t.kind === "expense" && (it.category?.name ?? "") === name).length },
      { formula: `IF(Summary!$B$4=0,0,B${r}/Summary!$B$4)`, result: s.spent > 0 ? c.spent / s.spent : 0 },
    ]);
  });
  cats.getColumn(2).numFmt = INR;
  cats.getColumn(4).numFmt = "0.0%";
  filters(cats);

  // Payees by total spent, grouped by the name shown on the Transactions sheet.
  header(payees, ["Payee", "Spent", "Payments", "Average payment"], [28, 16, 11, 18]);
  const byName = new Map<string, Item[]>();
  for (const it of d.items) {
    if (it.t.kind !== "expense" && it.t.kind !== "refund") continue;
    const name = it.t.payeeDisplay ?? it.t.payeeKey;
    if (!payeeKeyOf(it.t) || !name) continue;
    byName.set(name, [...(byName.get(name) ?? []), it]);
  }
  [...byName]
    .map(([name, txns]) => ({ name, spent: summarise(txns.map((x) => x.t)).spent, n: txns.filter((x) => x.t.kind === "expense").length }))
    .filter((p) => p.spent > 0)
    .sort((a, b) => b.spent - a.spent || a.name.localeCompare(b.name))
    .forEach((p, i) => {
      const r = i + 2;
      payees.addRow([
        p.name,
        { formula: spentWhere(T.payee, `A${r}`), result: rupees(p.spent) },
        { formula: `COUNTIFS(${types},"Payment",${range(T.payee)},A${r})`, result: p.n },
        { formula: `IF(C${r}=0,0,ROUND(B${r}/C${r},2))`, result: p.n ? Math.round(p.spent / p.n) / 100 : 0 },
      ]);
    });
  payees.getColumn(2).numFmt = INR;
  payees.getColumn(4).numFmt = INR;
  filters(payees);

  // Rooms that had anything in the range.
  header(rooms, ["Room", "Budget", "Spent", "Left"], [26, 16, 16, 16]);
  const roomIds = [...new Set(d.items.map((i) => i.t.roomId).filter((id): id is string => !!id))];
  roomIds.forEach((id, i) => {
    const info = d.lookup.rooms.get(id);
    const r = i + 2;
    const spent = summarise(d.items.filter((it) => it.t.roomId === id).map((it) => it.t)).spent;
    const budget = info?.budget ?? null;
    rooms.addRow([
      info?.name ?? "Room",
      budget === null ? null : rupees(budget),
      { formula: spentWhere(T.room, `A${r}`), result: rupees(spent) },
      budget === null ? null : { formula: `B${r}-C${r}`, result: rupees(budget - spent) },
    ]);
  });
  for (const c of [2, 3, 4]) rooms.getColumn(c).numFmt = INR;
  filters(rooms);

  return wb;
}

/** The workbook as a file, with exceljs loaded only now. */
export async function workbookBlob(d: ExportData): Promise<Blob> {
  const Excel = (await import("exceljs")).default;
  const buffer = await buildWorkbook(Excel, d).xlsx.writeBuffer();
  return new Blob([buffer], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
}
