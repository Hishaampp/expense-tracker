"use client";

import { ArrowRight } from "lucide-react";
import Link from "next/link";
import { useEffect, useRef } from "react";
import { categoryStyle } from "@/components/overview/category-style";
import { Amount } from "@/components/transactions/amount";
import { titleOf } from "@/components/transactions/table";
import { formatDate, formatPaise } from "@/lib/format/format";
import type { Item } from "@/lib/insights/tables";

export type BrowseEntry = { id: string; name: string; icon?: React.ReactNode; note: string; amount: number };

/**
 * A list to choose from beside the chosen one in full: two columns on a
 * wide screen, stacked on a phone (choosing scrolls to the detail).
 */
export function Browse({ label, entries, chosen, onChoose, children }: { label: string; entries: BrowseEntry[]; chosen: string | null; onChoose: (id: string) => void; children: React.ReactNode }) {
  const detail = useRef<HTMLDivElement>(null);
  const picked = useRef(false);
  useEffect(() => {
    if (!picked.current) return;
    picked.current = false;
    if (window.matchMedia("(max-width: 1023px)").matches) detail.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }, [chosen]);
  return (
    <div className="grid items-start gap-6 lg:grid-cols-[minmax(0,22rem)_minmax(0,1fr)]">
      <nav aria-label={label} className="rise overflow-hidden rounded-[1.25rem] border border-line bg-raised lg:sticky lg:top-8 lg:max-h-[calc(100dvh-4rem)] lg:overflow-y-auto" style={{ "--i": 2 } as React.CSSProperties}>
        <ul className="divide-y divide-line">
          {entries.map((e) => {
            const on = e.id === chosen;
            return (
              <li key={e.id}>
                <button
                  type="button"
                  aria-current={on ? "true" : undefined}
                  onClick={() => {
                    picked.current = true;
                    onChoose(e.id);
                  }}
                  className={`relative grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-x-3 px-4 py-3 text-left transition-colors ${on ? "bg-raised-2" : "hover:bg-raised-2/60"}`}
                >
                  {on && <span className="absolute inset-y-2 left-0 w-1 rounded-r-full bg-honey" aria-hidden />}
                  {e.icon ?? <span />}
                  <span className="min-w-0">
                    <span className="block truncate text-[0.9375rem] font-semibold">{e.name}</span>
                    <span className="block truncate text-[0.8125rem] text-ink-muted">{e.note}</span>
                  </span>
                  <span className="tabular text-[0.9375rem] font-semibold">{formatPaise(e.amount)}</span>
                </button>
              </li>
            );
          })}
        </ul>
      </nav>
      <div ref={detail} className="grid scroll-mt-20 gap-6">
        {children}
      </div>
    </div>
  );
}

/** Small numbers in a row: label over value. */
export function Stats({ items }: { items: [string, React.ReactNode][] }) {
  return (
    <dl className="grid grid-cols-2 gap-x-6 gap-y-4 sm:grid-cols-4">
      {items.map(([k, v]) => (
        <div key={k} className="grid gap-1">
          <dt className="text-[0.8125rem] text-ink-muted">{k}</dt>
          <dd className="tabular font-display text-[1.375rem] leading-tight">{v}</dd>
        </div>
      ))}
    </dl>
  );
}


/** The latest transactions of something, and a link to all of them in Transactions. */
export function Recent({ items, href, total }: { items: Item[]; href: string; total: number }) {
  return (
    <div className="grid gap-3">
      <ul className="grid gap-1">
        {items.map((i) => {
          const { Icon, color } = categoryStyle(i.category?.icon ?? null);
          return (
            <li key={i.t.id} className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-x-3 rounded-xl px-2 py-2 transition-colors hover:bg-raised-2">
              <span className="grid size-9 place-items-center rounded-xl text-on-tile" style={{ background: color }}>
                <Icon className="size-[16px]" strokeWidth={2} aria-hidden />
              </span>
              <span className="min-w-0">
                <span className="block truncate text-[0.9375rem] font-semibold">{titleOf(i)}</span>
                <span className="block truncate text-[0.8125rem] text-ink-muted">
                  {formatDate(i.t.at)}
                  {i.category ? ` · ${i.category.name}` : ""}
                </span>
              </span>
              <Amount kind={i.t.kind} paise={i.t.paise} className="text-[0.9375rem]" />
            </li>
          );
        })}
      </ul>
      {total > items.length && (
        <Link href={href} className="inline-flex items-center gap-1.5 justify-self-start rounded-full px-3 py-2 text-[0.875rem] font-semibold text-honey-text transition-colors hover:bg-honey-soft">
          All {total} in Transactions <ArrowRight className="size-4" aria-hidden />
        </Link>
      )}
    </div>
  );
}
