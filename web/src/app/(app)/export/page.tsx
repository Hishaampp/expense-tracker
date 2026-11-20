"use client";

import { Check, FileSpreadsheet, FileText, Filter as FilterIcon, LoaderCircle, ScrollText, ShieldAlert, type LucideIcon } from "lucide-react";
import { useMemo, useState } from "react";
import { PageHeader } from "@/components/ui/page-header";
import { formatCount, formatPaise } from "@/lib/format/format";
import type { RangeKey } from "@/lib/insights/ranges";
import { useLedger } from "@/lib/insights/use-ledger";
import { useSession } from "@/lib/session/session";
import { useQueryState } from "@/lib/url-state";
import { transactionsCsv } from "@/lib/export/csv";
import { download, exportData, type ExportData } from "@/lib/export/model";
import { filterFromParams, hasFilters, itemsIn, scopeOf } from "@/lib/export/scope";
import { NO_FILTER } from "@/lib/insights/tables";

const RANGES: [RangeKey, string][] = [
  ["this", "This month"],
  ["last", "Last month"],
  ["3m", "Last 3 months"],
  ["year", "Last 12 months"],
  ["all", "Everything"],
  ["custom", "Choose dates"],
];

type Format = { id: "xlsx" | "csv" | "pdf"; title: string; note: string; Icon: LucideIcon; file: (d: ExportData) => string; make: (d: ExportData) => Promise<Blob> };

const FORMATS: Format[] = [
  {
    id: "xlsx",
    title: "Excel",
    note: "Summary, Transactions, Categories, Payees and Rooms. Totals are live formulas; filters are on.",
    Icon: FileSpreadsheet,
    file: (d) => `ample-${d.slug}.xlsx`,
    make: async (d) => (await import("@/lib/export/xlsx")).workbookBlob(d),
  },
  {
    id: "csv",
    title: "CSV",
    note: "Every transaction, the same columns as the app's export. Opens in Google Sheets or anything else.",
    Icon: FileText,
    file: (d) => `ample-transactions-${d.slug}.csv`,
    make: async (d) => new Blob([transactionsCsv(d.items)], { type: "text/csv;charset=utf-8" }),
  },
  {
    id: "pdf",
    title: "PDF statement",
    note: "A branded statement: key numbers, where it went and every transaction. Good as an expense report.",
    Icon: ScrollText,
    file: (d) => `ample-statement-${d.slug}.pdf`,
    make: async (d) => (await import("@/lib/export/pdf")).statementBlob(d),
  },
];

type Status = "idle" | "making" | "done" | "failed";

/** Excel, CSV and a PDF statement, made here in the browser for any dates and the Transactions filters. */
export default function ExportPage() {
  const ledger = useLedger();
  const session = useSession();
  const [params, writeParams] = useQueryState();
  const [range, setRange] = useState<RangeKey>("this");
  const [custom, setCustom] = useState({ from: "", to: "" });
  const [status, setStatus] = useState<Record<string, Status>>({});
  const [dropFilters, setDropFilters] = useState(false);

  // Arriving from Transactions brings its dates too: all time there is everything here.
  const [readParams, setReadParams] = useState(false);
  if (params && !readParams) {
    setReadParams(true);
    const r = params.get("range") as RangeKey | null;
    if (r && RANGES.some(([k]) => k === r)) setRange(r);
    else if (hasFilters(filterFromParams(params))) setRange("all");
    setCustom({ from: params.get("from") ?? "", to: params.get("to") ?? "" });
  }

  const carried = useMemo(() => (params ? filterFromParams(params) : NO_FILTER), [params]);
  const filtered = hasFilters(carried) && !dropFilters;
  const data = useMemo(() => {
    if (!ledger) return null;
    const scope = scopeOf(range, ledger.vault, ledger.now, custom);
    const label = filtered ? `${scope.label} (filtered)` : scope.label;
    return exportData({
      ...scope,
      label,
      items: itemsIn(ledger.items, scope, filtered ? carried : NO_FILTER),
      lookup: ledger.lookup,
      monthlyBudget: null,
      email: session.status === "signed-in" ? (session.session.user.email ?? null) : null,
      generatedAt: new Date(),
    });
  }, [ledger, range, custom, carried, filtered, session]);

  if (!ledger || !data) return null;
  const incomplete = range === "custom" && (!custom.from || !custom.to);

  const run = async (f: Format) => {
    setStatus((s) => ({ ...s, [f.id]: "making" }));
    try {
      download(await f.make(data), f.file(data));
      setStatus((s) => ({ ...s, [f.id]: "done" }));
      window.setTimeout(() => setStatus((s) => ({ ...s, [f.id]: s[f.id] === "done" ? "idle" : s[f.id] })), 4000);
    } catch (error) {
      console.error(error);
      setStatus((s) => ({ ...s, [f.id]: "failed" }));
    }
  };

  const chip = "h-10 rounded-full border px-4 text-[0.875rem] font-semibold transition-colors";
  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <PageHeader title="Export" note="Take your records anywhere. Files are made here in your browser; nothing is sent anywhere." />

      <section aria-labelledby="which" className="rise grid gap-5 rounded-[1.25rem] border border-line bg-raised p-5 sm:p-7" style={{ "--i": 2 } as React.CSSProperties}>
        <h2 id="which" className="font-display text-[1.5rem] tracking-[-0.01em]">
          Which records
        </h2>
        <div className="flex flex-wrap items-center gap-2" role="radiogroup" aria-label="Dates">
          {RANGES.map(([key, label]) => (
            <button
              key={key}
              type="button"
              role="radio"
              aria-checked={range === key}
              onClick={() => setRange(key)}
              className={`${chip} ${range === key ? "border-honey/70 bg-honey-soft text-ink" : "border-line text-ink-muted hover:border-line-strong hover:text-ink"}`}
            >
              {label}
            </button>
          ))}
          {range === "custom" && (
            <span className="flex items-center gap-1.5">
              <label>
                <span className="sr-only">From</span>
                <input type="date" value={custom.from} onChange={(e) => setCustom({ ...custom, from: e.target.value })} className={`${chip} border-honey/70 bg-honey-soft px-3 text-ink`} />
              </label>
              <span className="text-ink-muted" aria-hidden>
                –
              </span>
              <label>
                <span className="sr-only">To</span>
                <input type="date" value={custom.to} onChange={(e) => setCustom({ ...custom, to: e.target.value })} className={`${chip} border-honey/70 bg-honey-soft px-3 text-ink`} />
              </label>
            </span>
          )}
        </div>
        {hasFilters(carried) && (
          <p className="flex flex-wrap items-center gap-x-3 gap-y-1 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] text-ink">
            <FilterIcon className="size-4 text-honey-text" aria-hidden />
            {dropFilters ? "Including everything, not just your Transactions filters." : "Only what matches your filters from Transactions."}
            <button
              type="button"
              onClick={() => {
                if (dropFilters) setDropFilters(false);
                else {
                  setDropFilters(true);
                  writeParams({ q: null, category: null, account: null, room: null, kind: null, origin: null, review: null });
                }
              }}
              className="font-semibold text-honey-text underline-offset-2 hover:underline"
            >
              {dropFilters ? "Use the filters" : "Include everything"}
            </button>
          </p>
        )}
        <p className="tabular flex flex-wrap gap-x-5 gap-y-1 text-[0.9375rem] text-ink-muted" aria-live="polite">
          <span className="font-semibold text-ink">{data.label}</span>
          <span>
            <span className="font-semibold text-ink">{formatCount(data.items.length)}</span> {data.items.length === 1 ? "transaction" : "transactions"}
          </span>
          <span>
            {data.summary.spent < 0 ? "Refunded" : "Spent"} <span className="font-semibold text-ink">{formatPaise(Math.abs(data.summary.spent))}</span>
          </span>
          <span>
            Money in <span className="font-semibold text-income">{formatPaise(data.summary.moneyIn)}</span>
          </span>
        </p>
      </section>

      <div className="grid gap-5 md:grid-cols-3">
        {FORMATS.map((f, i) => {
          const st = status[f.id] ?? "idle";
          return (
            <section key={f.id} aria-labelledby={`fmt-${f.id}`} className="rise grid content-between gap-6 rounded-[1.25rem] border border-line bg-raised p-6" style={{ "--i": 3 + i } as React.CSSProperties}>
              <div className="grid gap-3">
                <span className="grid size-12 place-items-center rounded-2xl bg-honey-soft text-honey-text">
                  <f.Icon className="size-[22px]" strokeWidth={1.85} aria-hidden />
                </span>
                <h2 id={`fmt-${f.id}`} className="font-display text-[1.375rem] tracking-[-0.01em]">
                  {f.title}
                </h2>
                <p className="text-[0.9375rem] leading-relaxed text-ink-muted">{f.note}</p>
              </div>
              <div className="grid gap-2">
                <button
                  type="button"
                  onClick={() => void run(f)}
                  disabled={st === "making" || incomplete}
                  className="inline-flex h-11 items-center justify-center gap-2 rounded-full bg-fill text-[0.9375rem] font-semibold text-on-fill shadow-[var(--shadow-near)] transition-transform hover:-translate-y-px active:translate-y-0 disabled:pointer-events-none disabled:opacity-50"
                >
                  {st === "making" ? <LoaderCircle className="size-4 animate-spin" aria-hidden /> : st === "done" ? <Check className="size-4" aria-hidden /> : null}
                  {st === "making" ? "Making…" : st === "done" ? "Downloaded" : `Download ${f.title}`}
                </button>
                <p className="min-h-5 text-center text-[0.8125rem] text-ink-muted" aria-live="polite">
                  {st === "failed" ? <span className="text-danger">Couldn&apos;t make the file. Try again.</span> : incomplete ? "Choose both dates first." : f.file(data)}
                </p>
              </div>
            </section>
          );
        })}
      </div>

      <p className="rise flex items-start gap-3 rounded-xl bg-sunken px-4 py-3 text-[0.9375rem] leading-relaxed text-ink-muted" style={{ "--i": 6 } as React.CSSProperties}>
        <ShieldAlert className="mt-0.5 size-[18px] shrink-0 text-honey-text" aria-hidden />
        These files aren&apos;t sealed: anyone who gets them can read them. Keep them somewhere private, and hidden transactions are left out, as on your phone.
      </p>
    </div>
  );
}
