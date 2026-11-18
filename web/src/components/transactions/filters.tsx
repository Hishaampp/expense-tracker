"use client";

import { Search, X } from "lucide-react";
import { forwardRef } from "react";
import type { Kind } from "@/lib/insights/money";
import type { RangeKey } from "@/lib/insights/ranges";
import { filterCount, NO_FILTER, type Filter, type Lookup } from "@/lib/insights/tables";


const field =
  "h-10 rounded-full border border-line bg-raised px-4 text-[0.875rem] font-semibold text-ink transition-colors hover:border-line-strong focus-visible:border-honey";

function Pick({ label, value, onChange, children }: { label: string; value: string; onChange: (v: string) => void; children: React.ReactNode }) {
  return (
    <label className="relative">
      <span className="sr-only">{label}</span>
      <select value={value} onChange={(e) => onChange(e.target.value)} className={`${field} cursor-pointer appearance-none pr-9 ${value ? "border-honey/70 bg-honey-soft" : ""}`}>
        {children}
      </select>
      <span className="pointer-events-none absolute top-1/2 right-3.5 -translate-y-1/2 text-[0.625rem] text-ink-muted" aria-hidden>
        ▼
      </span>
    </label>
  );
}

/** The search field; "/" focuses it from anywhere on the page. */
export const SearchField = forwardRef<HTMLInputElement, { value: string; onChange: (v: string) => void }>(function SearchField({ value, onChange }, ref) {
  return (
    <label className="relative block w-full sm:w-[22rem]">
      <span className="sr-only">Search payee, note, category, account or amount</span>
      <Search className="pointer-events-none absolute top-1/2 left-4 size-4 -translate-y-1/2 text-ink-muted" aria-hidden />
      <input
        ref={ref}
        type="search"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Search payee, note or amount"
        className="h-11 w-full rounded-full border border-line bg-raised pr-12 pl-11 text-[0.9375rem] text-ink shadow-[var(--shadow-near)] placeholder:text-ink-faint focus-visible:border-honey [&::-webkit-search-cancel-button]:hidden"
      />
      {value ? (
        <button type="button" onClick={() => onChange("")} aria-label="Clear search" className="absolute top-1/2 right-2 grid size-8 -translate-y-1/2 place-items-center rounded-full text-ink-muted hover:bg-raised-2 hover:text-ink">
          <X className="size-4" aria-hidden />
        </button>
      ) : (
        <kbd className="absolute top-1/2 right-3 -translate-y-1/2 rounded-md border border-line px-1.5 text-[0.75rem] text-ink-faint" aria-hidden>
          /
        </kbd>
      )}
    </label>
  );
});

/** Date range, category, account, Room, kind, source and needs review. */
export function FilterBar({ f, range, lookup, onChange, onRange, custom }: { f: Filter; range: RangeKey; lookup: Lookup; onChange: (f: Filter) => void; onRange: (r: RangeKey) => void; custom: React.ReactNode }) {
  const set = (patch: Partial<Filter>) => onChange({ ...f, ...patch });
  const byName = <T extends { name: string }>(xs: Iterable<T>) => [...xs].sort((a, b) => a.name.localeCompare(b.name));
  const categories = byName([...lookup.categories.values()].filter((c) => c.kind !== "system" && !c.archived));
  const accounts = byName([...lookup.accounts.values()].filter((a) => !a.archived));
  const rooms = byName(lookup.rooms.values());
  const count = filterCount(f);
  return (
    <div className="flex flex-wrap items-center gap-2" role="group" aria-label="Filters">
      <Pick label="Dates" value={range === "all" ? "" : range} onChange={(v) => onRange((v || "all") as RangeKey)}>
        <option value="">All time</option>
        <option value="this">This month</option>
        <option value="last">Last month</option>
        <option value="3m">Last 3 months</option>
        <option value="year">Last 12 months</option>
        <option value="custom">Choose dates…</option>
      </Pick>
      {custom}
      <Pick label="Category" value={f.categoryId ?? ""} onChange={(v) => set({ categoryId: v || null })}>
        <option value="">Any category</option>
        {categories.map((c) => (
          <option key={c.id} value={c.id}>
            {c.name}
          </option>
        ))}
      </Pick>
      <Pick label="Account" value={f.accountId ?? ""} onChange={(v) => set({ accountId: v || null })}>
        <option value="">Any account</option>
        {accounts.map((a) => (
          <option key={a.id} value={a.id}>
            {a.name}
          </option>
        ))}
      </Pick>
      {rooms.length > 0 && (
        <Pick label="Room" value={f.roomId ?? ""} onChange={(v) => set({ roomId: v || null })}>
          <option value="">Any Room</option>
          {rooms.map((r) => (
            <option key={r.id} value={r.id}>
              {r.emoji ? `${r.emoji} ` : ""}
              {r.name}
            </option>
          ))}
        </Pick>
      )}
      <Pick label="Kind" value={f.kind ?? ""} onChange={(v) => set({ kind: (v || null) as Kind | null })}>
        <option value="">Every kind</option>
        <option value="expense">Payments</option>
        <option value="income">Money in</option>
        <option value="refund">Refunds</option>
        <option value="transfer">Transfers</option>
      </Pick>
      <Pick label="How it was recorded" value={f.origin ?? ""} onChange={(v) => set({ origin: v || null })}>
        <option value="">Captured or typed</option>
        <option value="auto">Captured</option>
        <option value="manual">Typed in</option>
      </Pick>
      <button
        type="button"
        aria-pressed={f.needsReview}
        onClick={() => set({ needsReview: !f.needsReview })}
        className={`${field} ${f.needsReview ? "border-honey/70 bg-honey-soft" : ""}`}
      >
        Needs review
      </button>
      {count > 0 && (
        <button type="button" onClick={() => { onChange({ ...NO_FILTER, query: f.query }); onRange("all"); }} className="h-10 rounded-full px-3 text-[0.875rem] font-semibold text-honey-text hover:bg-honey-soft">
          Clear {count === 1 ? "filter" : `${count} filters`}
        </button>
      )}
    </div>
  );
}
