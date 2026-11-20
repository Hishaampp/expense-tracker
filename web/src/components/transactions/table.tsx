"use client";

import { formatDate, formatTime } from "@/lib/format/format";
import { ArrowDown, ArrowUp, Inbox } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { categoryStyle } from "@/components/overview/category-style";
import type { Item } from "@/lib/insights/tables";
import { Amount, ORIGIN_LABEL } from "./amount";

export type SortKey = "date" | "payee" | "category" | "account" | "amount";
export type Sort = { key: SortKey; desc: boolean };

const ROW = 64;
const OVERSCAN = 8;


/** What a row is called: the payee, else what kind of money it was. */
export function titleOf(i: Item): string {
  const t = i.t;
  if (t.kind === "transfer") return `${i.account?.name ?? "Account"} → ${i.toAccount?.name ?? "account"}`;
  return t.payeeDisplay ?? t.payeeKey ?? (t.kind === "income" ? "Money in" : t.kind === "refund" ? "Refund" : "Payment");
}

/** The line under a row's title: its note, else its Room, else its category. */
function subtitleOf(i: Item): string {
  return i.t.note ?? (i.room ? `${i.room.emoji ?? ""} ${i.room.name}`.trim() : (i.category?.name ?? ""));
}

const COLS = "grid-cols-[minmax(0,1fr)_auto] md:grid-cols-[7.5rem_minmax(0,1.6fr)_minmax(0,1fr)_minmax(0,0.9fr)_6.5rem_8.5rem]";

function Head({ label, k, sort, onSort, className = "" }: { label: string; k?: SortKey; sort?: Sort; onSort?: (s: Sort) => void; className?: string }) {
  const style = "text-[0.75rem] font-semibold tracking-wide uppercase";
  if (!k || !sort || !onSort)
    return (
      <span role="columnheader" className={`${style} text-ink-faint ${className}`}>
        {label}
      </span>
    );
  const on = sort.key === k;
  const Icon = sort.desc ? ArrowDown : ArrowUp;
  return (
    <span role="columnheader" aria-sort={on ? (sort.desc ? "descending" : "ascending") : "none"} className={className}>
      <button
        type="button"
        onClick={() => onSort({ key: k, desc: on ? !sort.desc : k === "date" || k === "amount" })}
        className={`inline-flex items-center gap-1 ${style} transition-colors hover:text-ink ${on ? "text-ink" : "text-ink-faint"}`}
      >
        {label}
        {on && <Icon className="size-3.5" aria-hidden />}
      </button>
    </span>
  );
}

/**
 * The transactions, drawn only where they can be seen so thousands of
 * rows scroll smoothly. [active] is the row j/k moves; Enter or a click
 * opens it.
 */
export function TransactionTable({ rows, sort, onSort, active, onActive, onOpen }: { rows: Item[]; sort: Sort; onSort: (s: Sort) => void; active: number; onActive: (i: number) => void; onOpen: (i: number) => void }) {
  const box = useRef<HTMLDivElement>(null);
  const [view, setView] = useState({ top: 0, height: 720 });
  useEffect(() => {
    const el = box.current;
    if (!el) return;
    const update = () => setView({ top: el.scrollTop, height: el.clientHeight });
    update();
    el.addEventListener("scroll", update, { passive: true });
    const ro = new ResizeObserver(update);
    ro.observe(el);
    return () => {
      el.removeEventListener("scroll", update);
      ro.disconnect();
    };
  }, []);
  // Keep the row j/k moved to in view.
  useEffect(() => {
    const el = box.current;
    if (!el || active < 0) return;
    const top = active * ROW;
    if (top < el.scrollTop) el.scrollTop = top;
    else if (top + ROW > el.scrollTop + el.clientHeight) el.scrollTop = top + ROW - el.clientHeight;
  }, [active]);

  const first = Math.max(0, Math.floor(view.top / ROW) - OVERSCAN);
  const last = Math.min(rows.length, Math.ceil((view.top + view.height) / ROW) + OVERSCAN);

  return (
    <div className="overflow-hidden rounded-[1.25rem] border border-line bg-raised">
      <div className={`grid ${COLS} items-center gap-x-4 border-b border-line bg-raised-2 px-5 py-3`} role="row">
        <Head label="Date" k="date" sort={sort} onSort={onSort} className="hidden md:block" />
        <Head label="Payee" k="payee" sort={sort} onSort={onSort} />
        <Head label="Category" k="category" sort={sort} onSort={onSort} className="hidden md:block" />
        <Head label="Account" k="account" sort={sort} onSort={onSort} className="hidden md:block" />
        <Head label="How" className="hidden md:block" />
        <Head label="Amount" k="amount" sort={sort} onSort={onSort} className="justify-self-end" />
      </div>
      <div ref={box} className="relative max-h-[min(70dvh,52rem)] overflow-y-auto" role="grid" aria-rowcount={rows.length} aria-label="Transactions">
        <div style={{ height: rows.length * ROW }} className="relative">
          {rows.slice(first, last).map((item, k) => {
            const index = first + k;
            const t = item.t;
            const { Icon, color } = categoryStyle(item.category?.icon ?? (t.kind === "transfer" ? "transfer" : t.kind === "income" ? "income" : null));
            const on = index === active;
            return (
              <div
                key={t.id}
                role="row"
                aria-rowindex={index + 1}
                aria-selected={on}
                onClick={() => onOpen(index)}
                onMouseEnter={() => onActive(index)}
                className={`absolute inset-x-0 grid ${COLS} cursor-pointer items-center gap-x-4 border-b border-line/60 px-5 transition-colors ${on ? "bg-raised-2" : ""}`}
                style={{ top: index * ROW, height: ROW }}
              >
                <span className="tabular hidden text-[0.875rem] text-ink-muted md:block">
                  {formatDate(t.at)}
                  <span className="block text-[0.75rem] text-ink-faint">{formatTime(t.at)}</span>
                </span>
                <span className="flex min-w-0 items-center gap-3">
                  <span className="grid size-9 shrink-0 place-items-center rounded-xl text-on-tile" style={{ background: color }}>
                    <Icon className="size-[16px]" strokeWidth={2} aria-hidden />
                  </span>
                  <span className="min-w-0">
                    <span className="flex items-center gap-2">
                      <span className="truncate text-[0.9375rem] font-semibold">{titleOf(item)}</span>
                      {t.needsReview && <Inbox className="size-3.5 shrink-0 text-honey-text" aria-label="Needs review" />}
                    </span>
                    <span className="block truncate text-[0.8125rem] text-ink-muted">
                      <span className="md:hidden">
                        {formatDate(t.at)}
                        {subtitleOf(item) && " · "}
                      </span>
                      {subtitleOf(item)}
                    </span>
                  </span>
                </span>
                <span className="hidden truncate text-[0.875rem] md:block">{item.category?.name ?? <span className="text-ink-faint">Uncategorised</span>}</span>
                <span className="hidden truncate text-[0.875rem] text-ink-muted md:block">{item.account?.name ?? "—"}</span>
                <span className="hidden text-[0.8125rem] text-ink-muted md:block">{ORIGIN_LABEL[t.origin] ?? t.origin}</span>
                <Amount kind={t.kind} paise={t.paise} className="justify-self-end text-[0.9375rem]" />
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
