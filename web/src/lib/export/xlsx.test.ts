import { writeFileSync } from "node:fs";
import ExcelJS from "exceljs";
import { describe, expect, it } from "vitest";
import type { Txn } from "@/lib/insights/money";
import { itemsOf, type Lookup } from "@/lib/insights/tables";
import { exportData } from "./model";
import { buildWorkbook } from "./xlsx";

const base: Txn = { id: "", kind: "expense", paise: 0, at: 0, categoryId: null, roomId: null, payeeKey: null, payeeDisplay: null, hidden: false, needsReview: false, accountId: "hdfc", toAccountId: null, note: null, origin: "manual", instrument: null, refNo: null, linkedId: null, createdAt: 0 };
let n = 0;
const t = (p: Partial<Txn>): Txn => ({ ...base, id: `t${n++}`, ...p });
const at = (d: number, h = 12) => new Date(2026, 10, d, h).getTime();

const lookup: Lookup = {
  categories: new Map([
    ["food", { id: "food", name: "Food", icon: "food", kind: "expense", archived: false }],
    ["rent", { id: "rent", name: "Rent", icon: "rent", kind: "expense", archived: false }],
  ]),
  accounts: new Map([
    ["hdfc", { id: "hdfc", name: "HDFC", archived: false }],
    ["card", { id: "card", name: "Card", archived: false }],
  ]),
  rooms: new Map([["goa", { id: "goa", name: "Goa", emoji: null, type: "trip", startDay: null, endDay: null, budget: 500000, countsTowardBudget: false, archived: false }]]),
};

const txns = [
  t({ paise: 2800000, at: at(3), categoryId: "rent", payeeKey: "landlord", payeeDisplay: "Rent" }),
  t({ paise: 24050, at: at(4), categoryId: "food", payeeKey: "swiggy", payeeDisplay: "Swiggy" }),
  t({ paise: 15000, at: at(6), categoryId: "food", payeeKey: "swiggy", payeeDisplay: "Swiggy", roomId: "goa" }),
  t({ kind: "refund", paise: 5050, at: at(7), categoryId: "food", payeeKey: "swiggy", payeeDisplay: "Swiggy" }),
  t({ paise: 999, at: at(8) }),
  t({ kind: "income", paise: 8500000, at: at(1, 9), payeeDisplay: "Acme" }),
  t({ kind: "transfer", paise: 100000, at: at(5), toAccountId: "card" }),
  t({ paise: 77777, at: at(9), hidden: true }),
];

const data = exportData({
  label: "November 2026",
  slug: "2026-11",
  from: new Date(2026, 10, 1).getTime(),
  to: new Date(2026, 11, 1).getTime(),
  items: itemsOf(txns, lookup),
  days: 19,
  lookup,
  monthlyBudget: null,
  email: "a@example.com",
  generatedAt: new Date(2026, 10, 19),
});

/** Builds, writes and reads the file back, as Excel would open it. */
async function roundTrip() {
  const buffer = await buildWorkbook(ExcelJS, data).xlsx.writeBuffer();
  // A copy to open in a spreadsheet app, when asked: SAVE_XLSX=path npm test.
  if (process.env.SAVE_XLSX) writeFileSync(process.env.SAVE_XLSX, new Uint8Array(buffer as ArrayBuffer));
  const wb = new ExcelJS.Workbook();
  await wb.xlsx.load(buffer);
  return wb;
}
const result = (v: ExcelJS.CellValue) => (v as ExcelJS.CellFormulaValue).result;
const formula = (v: ExcelJS.CellValue) => (v as ExcelJS.CellFormulaValue).formula;

describe("Excel workbook", () => {
  it("has the five sheets, hidden ones left out, oldest first", async () => {
    const wb = await roundTrip();
    expect(wb.worksheets.map((s) => s.name)).toEqual(["Summary", "Transactions", "Categories", "Payees", "Rooms"]);
    const tx = wb.getWorksheet("Transactions")!;
    expect(tx.rowCount).toBe(1 + 7);
    expect(tx.getRow(2).getCell(3).value).toBe("Money in");
    expect(tx.getRow(2).getCell(4).value).toBe(85000);
    expect(tx.getColumn(4).numFmt).toContain("₹");
    expect(tx.views[0]).toMatchObject({ state: "frozen", ySplit: 1 });
    expect(tx.autoFilter).toBeTruthy();
  });

  it("totals are live formulas whose values match the app's maths", async () => {
    const s = (await roundTrip()).getWorksheet("Summary")!;
    const spent = s.getCell("B4").value;
    expect(formula(spent)).toContain('SUMIFS(Transactions!$D$2:$D$8,Transactions!$C$2:$C$8,"Payment")');
    // 28,000 + 240.50 + 150 + 9.99 − 50.50 refund; the transfer and the hidden payment don't count.
    expect(result(spent)).toBeCloseTo(28349.99, 2);
    expect(data.summary.spent).toBe(2834999);
    expect(result(s.getCell("B5").value)).toBe(85000);
    expect(result(s.getCell("B6").value)).toBeCloseTo(56650.01, 2);
    expect(result(s.getCell("B7").value)).toBe(4);
    expect(result(s.getCell("B9").value)).toBeCloseTo(1492.1, 2);
  });

  it("splits by category, payee and Room with formulas over the Transactions sheet", async () => {
    const wb = await roundTrip();
    const cats = wb.getWorksheet("Categories")!;
    expect(cats.getRow(2).getCell(1).value).toBe("Rent");
    expect(cats.getRow(3).getCell(1).value).toBe("Food");
    expect(result(cats.getRow(3).getCell(2).value)).toBeCloseTo(340, 2);
    expect(formula(cats.getRow(3).getCell(2).value)).toContain("Transactions!$E$2:$E$8,A3");
    expect(cats.getRow(4).getCell(1).value).toBe("Uncategorised");
    expect(formula(cats.getRow(4).getCell(2).value)).toContain('Transactions!$E$2:$E$8,""');

    const payees = wb.getWorksheet("Payees")!;
    const swiggy = payees.getRow(3);
    expect(swiggy.getCell(1).value).toBe("Swiggy");
    expect(result(swiggy.getCell(2).value)).toBeCloseTo(340, 2);
    expect(result(swiggy.getCell(3).value)).toBe(2);
    expect(result(swiggy.getCell(4).value)).toBeCloseTo(170, 2);

    const rooms = wb.getWorksheet("Rooms")!;
    expect(rooms.getRow(2).getCell(1).value).toBe("Goa");
    expect(rooms.getRow(2).getCell(2).value).toBe(5000);
    expect(result(rooms.getRow(2).getCell(4).value)).toBe(4850);
  });
});
