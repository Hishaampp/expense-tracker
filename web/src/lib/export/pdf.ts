/**
 * The PDF statement: Ample's mark and fonts, the key numbers, where the
 * money went, and every transaction, on A4 with page numbers. Made in the
 * browser; the brand fonts are embedded because the PDF's built-in fonts
 * have no ₹.
 */
import type { jsPDF as JsPdf } from "jspdf";
import type { autoTable as AutoTable } from "jspdf-autotable";
import { formatDate, formatPaise } from "@/lib/format/format";
import { categoryColor } from "./colors";
import { dailyAverage, KIND_WORDS, type ExportData } from "./model";

export type PdfFonts = { regular: Uint8Array; bold: Uint8Array; display: Uint8Array };

// The light theme's tokens (globals.css), as PDF colours.
const INK: [number, number, number] = [18, 18, 18];
const MUTED: [number, number, number] = [97, 97, 97];
const HONEY: [number, number, number] = [242, 179, 61];
const CREAM: [number, number, number] = [252, 235, 196];
const LINE: [number, number, number] = [234, 227, 214];
const SUNKEN: [number, number, number] = [244, 239, 229];
const INCOME: [number, number, number] = [27, 115, 70];

const PAGE_W = 210;
const PAGE_H = 297;
const M = 16;
const TOP_CATEGORIES = 8;

function toBase64(bytes: Uint8Array): string {
  let s = "";
  for (let i = 0; i < bytes.length; i += 0x8000) s += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  return btoa(s);
}

/** Ample's mark: the ring and stem in ink, honey in the bowl. */
function mark(doc: JsPdf, x: number, y: number, size: number) {
  const k = size / 100;
  doc.setFillColor(...HONEY);
  doc.circle(x + 50 * k, y + 54 * k, 19 * k, "F");
  doc.setFillColor(255, 255, 255);
  doc.rect(x + 30 * k, y + 30 * k, 40 * k, 22 * k, "F");
  doc.setDrawColor(...INK);
  doc.setLineWidth(10 * k);
  doc.circle(x + 50 * k, y + 50 * k, 28 * k, "S");
  doc.setFillColor(...INK);
  doc.roundedRect(x + 73 * k, y + 17 * k, 10 * k, 66 * k, 5 * k, 5 * k, "F");
}

/** Builds the statement. [Pdf] and [autoTable] are loaded on demand in the browser. */
export function buildStatement(Pdf: typeof JsPdf, autoTable: typeof AutoTable, d: ExportData, fonts: PdfFonts): JsPdf {
  const doc = new Pdf({ unit: "mm", format: "a4", compress: true });
  doc.setProperties({ title: `Ample statement, ${d.label}`, creator: "Ample", subject: "Statement" });
  doc.addFileToVFS("Manrope-Regular.ttf", toBase64(fonts.regular));
  doc.addFont("Manrope-Regular.ttf", "Manrope", "normal");
  doc.addFileToVFS("Manrope-Bold.ttf", toBase64(fonts.bold));
  doc.addFont("Manrope-Bold.ttf", "Manrope", "bold");
  doc.addFileToVFS("Fraunces.ttf", toBase64(fonts.display));
  doc.addFont("Fraunces.ttf", "Fraunces", "normal");

  // Header: the lockup on the left, what this is on the right.
  mark(doc, M, 14, 11);
  doc.setFont("Fraunces", "normal");
  doc.setFontSize(18);
  doc.setTextColor(...INK);
  doc.text("Ample", M + 13.5, 22.6);
  doc.setFontSize(11);
  doc.setTextColor(...MUTED);
  doc.setFont("Manrope", "normal");
  doc.text("Statement", PAGE_W - M, 18, { align: "right" });
  doc.setFont("Fraunces", "normal");
  doc.setFontSize(16);
  doc.setTextColor(...INK);
  doc.text(d.label, PAGE_W - M, 25, { align: "right" });

  doc.setDrawColor(...LINE);
  doc.setLineWidth(0.3);
  doc.line(M, 31, PAGE_W - M, 31);
  doc.setFont("Manrope", "normal");
  doc.setFontSize(9);
  doc.setTextColor(...MUTED);
  doc.text([d.email, `Made ${formatDate(d.generatedAt)}`].filter(Boolean).join("  ·  "), M, 37);

  // Key numbers.
  const s = d.summary;
  const avg = dailyAverage(d);
  const payments = d.items.filter((i) => i.t.kind === "expense").length;
  const kept = s.moneyIn - s.spent;
  const boxes: [string, string, [number, number, number]?][] = [
    [s.spent < 0 ? "Refunded" : "Spent", formatPaise(Math.abs(s.spent))],
    ["Money in", formatPaise(s.moneyIn), INCOME],
    [kept < 0 ? "Short by" : "Kept", formatPaise(Math.abs(kept))],
    avg !== null ? ["Daily average", formatPaise(avg)] : ["Payments", String(payments)],
  ];
  const gap = 4;
  const bw = (PAGE_W - 2 * M - gap * 3) / 4;
  boxes.forEach(([label, value, tone], i) => {
    const x = M + i * (bw + gap);
    doc.setFillColor(...(i === 0 ? CREAM : SUNKEN));
    doc.roundedRect(x, 43, bw, 22, 3, 3, "F");
    doc.setFont("Manrope", "normal");
    doc.setFontSize(8.5);
    doc.setTextColor(...MUTED);
    doc.text(label, x + 4, 50);
    doc.setFont("Fraunces", "normal");
    doc.setFontSize(value.length > 12 ? 12 : 14);
    doc.setTextColor(...(tone ?? INK));
    doc.text(value, x + 4, 59.5);
  });

  // Where it went: the largest categories with their share.
  let y = 76;
  doc.setFont("Fraunces", "normal");
  doc.setFontSize(13);
  doc.setTextColor(...INK);
  doc.text("Where it went", M, y);
  y += 6;
  const cats = s.byCategory.slice(0, TOP_CATEGORIES);
  if (cats.length === 0) {
    doc.setFont("Manrope", "normal");
    doc.setFontSize(9.5);
    doc.setTextColor(...MUTED);
    doc.text("No spending in this period.", M, y + 3);
    y += 8;
  }
  for (const c of cats) {
    const cat = c.categoryId ? d.lookup.categories.get(c.categoryId) : undefined;
    const share = s.spent > 0 ? c.spent / s.spent : 0;
    doc.setFont("Manrope", "normal");
    doc.setFontSize(9.5);
    doc.setTextColor(...INK);
    doc.text(cat?.name ?? "Uncategorised", M, y + 3);
    doc.setFillColor(...SUNKEN);
    doc.roundedRect(M + 45, y, 95, 3.2, 1.6, 1.6, "F");
    doc.setFillColor(...categoryColor(cat?.icon ?? null));
    doc.roundedRect(M + 45, y, Math.max(1.6, 95 * share), 3.2, 1.6, 1.6, "F");
    doc.setTextColor(...MUTED);
    doc.text(`${Math.round(share * 100)}%`, M + 144, y + 3);
    doc.setFont("Manrope", "bold");
    doc.setTextColor(...INK);
    doc.text(formatPaise(c.spent), PAGE_W - M, y + 3, { align: "right" });
    y += 7;
  }
  if (s.byCategory.length > TOP_CATEGORIES) {
    const rest = s.byCategory.slice(TOP_CATEGORIES).reduce((a, c) => a + c.spent, 0);
    doc.setFont("Manrope", "normal");
    doc.setFontSize(9);
    doc.setTextColor(...MUTED);
    doc.text(`${s.byCategory.length - TOP_CATEGORIES} more categories`, M, y + 3);
    doc.text(formatPaise(rest), PAGE_W - M, y + 3, { align: "right" });
    y += 7;
  }

  // Every transaction.
  y += 6;
  doc.setFont("Fraunces", "normal");
  doc.setFontSize(13);
  doc.setTextColor(...INK);
  doc.text("Transactions", M, y);
  autoTable(doc, {
    startY: y + 3,
    margin: { left: M, right: M, bottom: 18, top: 18 },
    theme: "plain",
    head: [["Date", "Payee", "Category", "Account", "Amount"]],
    body: d.items.map(({ t, category, account, toAccount }) => [
      formatDate(t.at),
      t.kind === "transfer"
        ? `${KIND_WORDS.transfer}: ${account?.name ?? ""} → ${toAccount?.name ?? ""}`
        : [t.payeeDisplay ?? t.payeeKey ?? KIND_WORDS[t.kind], t.note].filter(Boolean).join("\n"),
      category?.name ?? (t.kind === "transfer" ? "" : t.kind === "income" ? KIND_WORDS.income : "Uncategorised"),
      account?.name ?? "",
      `${t.kind === "income" || t.kind === "refund" ? "+" : ""}${formatPaise(t.paise)}`,
    ]),
    styles: { font: "Manrope", fontSize: 8.5, textColor: INK, cellPadding: { top: 2.2, bottom: 2.2, left: 2, right: 2 }, lineColor: LINE, lineWidth: { bottom: 0.2 } },
    headStyles: { font: "Manrope", fontStyle: "bold", fillColor: HONEY, textColor: INK, lineWidth: 0 },
    columnStyles: { 0: { cellWidth: 24, textColor: MUTED }, 2: { cellWidth: 30 }, 3: { cellWidth: 30, textColor: MUTED }, 4: { cellWidth: 28, halign: "right", fontStyle: "bold" } },
    didParseCell: (cell) => {
      if (cell.column.index !== 4) return;
      cell.cell.styles.halign = "right";
      if (cell.section !== "body") return;
      const kind = d.items[cell.row.index]?.t.kind;
      if (kind === "income" || kind === "refund") cell.cell.styles.textColor = INCOME;
      if (kind === "transfer") cell.cell.styles.textColor = MUTED;
    },
  });
  if (d.items.length === 0) {
    doc.setFont("Manrope", "normal");
    doc.setFontSize(9.5);
    doc.setTextColor(...MUTED);
    doc.text("Nothing recorded in this period.", M, y + 16);
  }

  // Footer on every page.
  const pages = doc.getNumberOfPages();
  for (let p = 1; p <= pages; p++) {
    doc.setPage(p);
    doc.setFont("Manrope", "normal");
    doc.setFontSize(7.5);
    doc.setTextColor(...MUTED);
    doc.text(`Ample statement · ${d.label} · Made in your browser; hidden transactions are left out, refunds reduce spending.`, M, PAGE_H - 9);
    doc.text(`Page ${p} of ${pages}`, PAGE_W - M, PAGE_H - 9, { align: "right" });
  }
  return doc;
}

/** The statement as a file, with jsPDF and the fonts loaded only now. */
export async function statementBlob(d: ExportData): Promise<Blob> {
  const [{ jsPDF }, { autoTable }, regular, bold, display] = await Promise.all([
    import("jspdf"),
    import("jspdf-autotable"),
    ...["Manrope-Regular", "Manrope-Bold", "Fraunces-SoftSemiBold"].map(async (f) => new Uint8Array(await (await fetch(`/pdf-fonts/${f}.ttf`)).arrayBuffer())),
  ] as const);
  return buildStatement(jsPDF, autoTable, d, { regular, bold, display }).output("blob");
}
