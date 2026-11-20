import { readFileSync, writeFileSync } from "node:fs";
import { jsPDF } from "jspdf";
import { autoTable } from "jspdf-autotable";
import { describe, expect, it } from "vitest";
import type { Txn } from "@/lib/insights/money";
import { itemsOf, type Lookup } from "@/lib/insights/tables";
import { exportData } from "./model";
import { buildStatement } from "./pdf";

const font = (name: string) => new Uint8Array(readFileSync(`public/pdf-fonts/${name}.ttf`));
const fonts = { regular: font("Manrope-Regular"), bold: font("Manrope-Bold"), display: font("Fraunces-SoftSemiBold") };

const base: Txn = { id: "", kind: "expense", paise: 0, at: 0, categoryId: null, roomId: null, payeeKey: null, payeeDisplay: null, hidden: false, needsReview: false, accountId: "hdfc", toAccountId: null, note: null, origin: "manual", instrument: null, refNo: null, linkedId: null, createdAt: 0 };
const lookup: Lookup = {
  categories: new Map(
    ["food", "groceries", "transport", "shopping", "rent", "bills", "health", "fuel", "travel", "gifts"].map((id) => [id, { id, name: id[0].toUpperCase() + id.slice(1), icon: id, kind: "expense", archived: false }]),
  ),
  accounts: new Map([
    ["hdfc", { id: "hdfc", name: "HDFC Savings", archived: false }],
    ["card", { id: "card", name: "ICICI Card", archived: false }],
  ]),
  rooms: new Map(),
};
const cats = [...lookup.categories.keys()];
const payees = ["Swiggy", "BigBasket", "Uber", "Amazon", "Apollo Pharmacy", "HP Petrol"];

function statement(count: number) {
  const txns: Txn[] = Array.from({ length: count }, (_, i) => ({
    ...base,
    id: `t${i}`,
    kind: i === 0 ? "income" : i % 17 === 0 ? "refund" : i % 23 === 0 ? "transfer" : "expense",
    toAccountId: i % 23 === 0 ? "card" : null,
    paise: i === 0 ? 8500000 : 1999 + ((i * 7919) % 350000),
    at: new Date(2026, 10, 1 + (i % 18), 9 + (i % 12)).getTime(),
    categoryId: i % 23 === 0 ? null : cats[i % cats.length],
    payeeDisplay: i === 0 ? "Acme Salary" : payees[i % payees.length],
    note: i % 9 === 0 ? "Dinner with Asha, split three ways" : null,
  }));
  const data = exportData({
    label: "November 2026",
    slug: "2026-11",
    from: new Date(2026, 10, 1).getTime(),
    to: new Date(2026, 11, 1).getTime(),
    items: itemsOf(txns, lookup),
    days: 18,
    lookup,
    monthlyBudget: null,
    email: "you@example.com",
    generatedAt: new Date(2026, 10, 18),
  });
  return buildStatement(jsPDF, autoTable, data, fonts);
}

describe("PDF statement", () => {
  it("is a real PDF that runs over as many pages as the transactions need", () => {
    const doc = statement(150);
    const bytes = new Uint8Array(doc.output("arraybuffer"));
    expect(new TextDecoder().decode(bytes.subarray(0, 5))).toBe("%PDF-");
    expect(doc.getNumberOfPages()).toBeGreaterThanOrEqual(4);
    // A look at it, when asked: SAVE_PDF=path npm test.
    if (process.env.SAVE_PDF) writeFileSync(process.env.SAVE_PDF, bytes);
  });

  it("still makes a one-page statement for a quiet month", () => {
    const doc = statement(0);
    expect(doc.getNumberOfPages()).toBe(1);
  });
});
