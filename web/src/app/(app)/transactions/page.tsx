"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { TransactionDetail } from "@/components/transactions/detail";
import { FilterBar, SearchField } from "@/components/transactions/filters";
import { TransactionTable, titleOf, type Sort } from "@/components/transactions/table";
import { Quiet } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";
import { formatCount, formatPaise } from "@/lib/format/format";
import { summarise, type Kind } from "@/lib/insights/money";
import { rangeBounds, type RangeKey } from "@/lib/insights/ranges";
import { matches, NO_FILTER, type Filter, type Item } from "@/lib/insights/tables";
import { useLedger } from "@/lib/insights/use-ledger";
import { useQueryState } from "@/lib/url-state";

const RANGES: RangeKey[] = ["all", "this", "last", "3m", "year", "custom"];
const KINDS: Kind[] = ["expense", "income", "refund", "transfer"];

function compare(sort: Sort) {
  const dir = sort.desc ? -1 : 1;
  const text = (a: string, b: string) => a.localeCompare(b, "en-IN", { sensitivity: "base" });
  return (a: Item, b: Item) => {
    let d = 0;
    if (sort.key === "amount") d = a.t.paise - b.t.paise;
    else if (sort.key === "payee") d = text(titleOf(a), titleOf(b));
    else if (sort.key === "category") d = text(a.category?.name ?? "~", b.category?.name ?? "~");
    else if (sort.key === "account") d = text(a.account?.name ?? "~", b.account?.name ?? "~");
    // Ties, and the date column itself, fall back to newest or oldest first.
    return d * dir || (a.t.at - b.t.at) * (sort.key === "date" ? dir : -1) || (a.t.createdAt - b.t.createdAt) * -1;
  };
}

const typing = (el: EventTarget | null) => el instanceof HTMLElement && (el.tagName === "INPUT" || el.tagName === "SELECT" || el.tagName === "TEXTAREA" || el.isContentEditable);

export default function TransactionsPage() {
  const ledger = useLedger();
  const [params, writeParams] = useQueryState();
  const [filter, setFilter] = useState<Filter>(NO_FILTER);
  const [range, setRange] = useState<RangeKey>("all");
  const [custom, setCustom] = useState<{ from: string; to: string }>({ from: "", to: "" });
  const [sort, setSort] = useState<Sort>({ key: "date", desc: true });
  const [active, setActive] = useState(0);
  const [openId, setOpenId] = useState<string | null>(null);
  const search = useRef<HTMLInputElement>(null);

  // The address is read once it is known: a link from another page arrives filtered.
  const [readParams, setReadParams] = useState(false);
  if (params && !readParams) {
    setReadParams(true);
    const kind = params.get("kind");
    const r = params.get("range") as RangeKey | null;
    setFilter({
      ...NO_FILTER,
      query: params.get("q") ?? "",
      categoryId: params.get("category"),
      accountId: params.get("account"),
      roomId: params.get("room"),
      kind: kind && (KINDS as string[]).includes(kind) ? (kind as Kind) : null,
      origin: params.get("origin"),
      needsReview: params.get("review") === "1",
    });
    if (r && RANGES.includes(r)) setRange(r);
    setCustom({ from: params.get("from") ?? "", to: params.get("to") ?? "" });
  }

  const update = useCallback(
    (f: Filter, r: RangeKey, c: { from: string; to: string }) => {
      setFilter(f);
      setRange(r);
      setCustom(c);
      setActive(0);
      writeParams({
        q: f.query.trim() || null,
        category: f.categoryId,
        account: f.accountId,
        room: f.roomId,
        kind: f.kind,
        origin: f.origin,
        review: f.needsReview ? "1" : null,
        range: r === "all" ? null : r,
        from: r === "custom" ? c.from || null : null,
        to: r === "custom" ? c.to || null : null,
      });
    },
    [writeParams],
  );

  const bounds = useMemo(() => (ledger ? rangeBounds(range, ledger.vault, ledger.now, custom.from, custom.to) : { from: null, to: null }), [ledger, range, custom]);
  // Like the app's Activity: hidden transactions are left out.
  const rows = useMemo(() => {
    if (!ledger) return [];
    const f = { ...filter, ...bounds };
    return ledger.items.filter((i) => !i.t.hidden && matches(i, f)).sort(compare(sort));
  }, [ledger, filter, bounds, sort]);
  const totals = useMemo(() => summarise(rows.map((i) => i.t)), [rows]);
  const byId = useMemo(() => new Map(ledger?.items.map((i) => [i.t.id, i]) ?? []), [ledger]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (e.key === "Escape") {
        if (openId) setOpenId(null);
        else if (document.activeElement === search.current && filter.query) update({ ...filter, query: "" }, range, custom);
        else search.current?.blur();
        return;
      }
      if (typing(e.target)) return;
      if (e.key === "/") {
        e.preventDefault();
        search.current?.focus();
      } else if (e.key === "j" || e.key === "ArrowDown") {
        e.preventDefault();
        setActive((a) => Math.min(rows.length - 1, a + 1));
      } else if (e.key === "k" || e.key === "ArrowUp") {
        e.preventDefault();
        setActive((a) => Math.max(0, a - 1));
      } else if (e.key === "Enter" && rows[active]) {
        setOpenId(rows[active].t.id);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [openId, filter, range, custom, update, rows, active]);

  if (!ledger) return null;
  const open = openId ? byId.get(openId) : undefined;
  const linked = open
    ? open.t.kind === "refund"
      ? [open.t.linkedId ? byId.get(open.t.linkedId) : undefined].filter((x): x is Item => !!x)
      : ledger.items.filter((i) => i.t.kind === "refund" && i.t.linkedId === open.t.id)
    : [];
  const dateField = "h-10 rounded-full border border-honey/70 bg-honey-soft px-3 text-[0.875rem] font-semibold text-ink";

  return (
    <div className="mx-auto grid max-w-[76rem] gap-6">
      <PageHeader title="Transactions" note={<>Everything recorded, newest first.<span className="hidden lg:inline"> Press <kbd className="rounded-md border border-line px-1.5 text-[0.875rem]">/</kbd> to search and <kbd className="rounded-md border border-line px-1.5 text-[0.875rem]">j</kbd> <kbd className="rounded-md border border-line px-1.5 text-[0.875rem]">k</kbd> to move.</span></>}>
        <SearchField ref={search} value={filter.query} onChange={(q) => update({ ...filter, query: q }, range, custom)} />
      </PageHeader>

      <div className="rise grid gap-4" style={{ "--i": 2 } as React.CSSProperties}>
        <FilterBar
          f={filter}
          range={range}
          lookup={ledger.lookup}
          onChange={(f) => update(f, range, custom)}
          onRange={(r) => update(filter, r, custom)}
          custom={
            range === "custom" && (
              <span className="flex items-center gap-1.5">
                <label>
                  <span className="sr-only">From</span>
                  <input type="date" value={custom.from} onChange={(e) => update(filter, range, { ...custom, from: e.target.value })} className={dateField} />
                </label>
                <span className="text-ink-muted" aria-hidden>
                  –
                </span>
                <label>
                  <span className="sr-only">To</span>
                  <input type="date" value={custom.to} onChange={(e) => update(filter, range, { ...custom, to: e.target.value })} className={dateField} />
                </label>
              </span>
            )
          }
        />
        <p className="tabular flex flex-wrap gap-x-5 gap-y-1 text-[0.9375rem] text-ink-muted" aria-live="polite">
          <span>
            <span className="font-semibold text-ink">{formatCount(rows.length)}</span> {rows.length === 1 ? "transaction" : "transactions"}
          </span>
          <span>
            {totals.spent < 0 ? "Refunded" : "Spent"} <span className={`font-semibold ${totals.spent < 0 ? "text-income" : "text-ink"}`}>{formatPaise(Math.abs(totals.spent))}</span>
          </span>
          <span>
            Money in <span className="font-semibold text-income">{formatPaise(totals.moneyIn)}</span>
          </span>
          {totals.moneyIn > 0 && (
            <span>
              {totals.moneyIn - totals.spent < 0 ? "Short by" : "Kept"} <span className="font-semibold text-ink">{formatPaise(Math.abs(totals.moneyIn - totals.spent))}</span>
            </span>
          )}
        </p>
      </div>

      <div className="rise" style={{ "--i": 3 } as React.CSSProperties}>
        {rows.length ? (
          <TransactionTable rows={rows} sort={sort} onSort={(s) => { setSort(s); setActive(0); }} active={active} onActive={setActive} onOpen={(i) => { setActive(i); setOpenId(rows[i].t.id); }} />
        ) : (
          <Quiet>{ledger.items.length ? "Nothing matches. Try fewer filters or another search." : "Nothing recorded yet. Payments you add or Ample captures on your phone appear here."}</Quiet>
        )}
      </div>

      {open && (
        <>
          <button type="button" aria-label="Close details" className="fixed inset-0 z-30 bg-black/30 md:bg-transparent" onClick={() => setOpenId(null)} />
          <TransactionDetail item={open} linked={linked} onClose={() => setOpenId(null)} onOpen={setOpenId} />
        </>
      )}
    </div>
  );
}
