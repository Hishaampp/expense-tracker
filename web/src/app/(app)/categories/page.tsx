"use client";

import { useMemo } from "react";
import { Browse, Recent, Stats } from "@/components/browse/browse";
import { categoryStyle } from "@/components/overview/category-style";
import { TrendChart } from "@/components/overview/trend-chart";
import { Card, Quiet } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";
import { formatCount, formatPaise } from "@/lib/format/format";
import { monthlyAverage, totalsFor, yearOf, type Totals } from "@/lib/insights/browse";
import type { Period } from "@/lib/insights/period";
import type { Named } from "@/lib/insights/tables";
import { useLedger, type Ledger } from "@/lib/insights/use-ledger";
import { useQueryState } from "@/lib/url-state";

const RECENT = 8;

/** Each category: the last 12 months, its budget, and its latest transactions. */
export default function CategoriesPage() {
  const ledger = useLedger();
  const [params, write] = useQueryState();

  const data = useMemo(() => {
    if (!ledger) return null;
    const { months } = yearOf(ledger.vault, ledger.now);
    const budgets = new Map<string, number>();
    for (const b of ledger.vault.tables.budgets.values()) if (typeof b.category_id === "string" && b.category_id) budgets.set(b.category_id, Number(b.amount_paise));
    const lines = [...ledger.lookup.categories.values()]
      .filter((c) => c.kind !== "system")
      .map((c) => ({ c, totals: totalsFor(ledger.txns, months, (t) => t.categoryId === c.id), budget: budgets.get(c.id) ?? null }))
      .filter((l) => !l.c.archived || l.totals.spent !== 0 || l.totals.moneyIn !== 0)
      .sort((a, b) => Number(a.c.kind === "income") - Number(b.c.kind === "income") || Math.max(b.totals.spent, b.totals.moneyIn) - Math.max(a.totals.spent, a.totals.moneyIn) || a.c.name.localeCompare(b.c.name));
    return { months, lines };
  }, [ledger]);

  if (!ledger || !data) return null;
  const chosenId = params?.get("id") ?? data.lines[0]?.c.id ?? null;
  const chosen = data.lines.find((l) => l.c.id === chosenId) ?? data.lines[0];

  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <PageHeader title="Categories" note="Each category over the last 12 months." />
      {!chosen ? (
        <Quiet>No categories yet.</Quiet>
      ) : (
        <Browse
          label="Categories"
          chosen={chosen.c.id}
          onChoose={(id) => write({ id })}
          entries={data.lines.map(({ c, totals }) => {
            const { Icon, color } = categoryStyle(c.icon);
            const income = c.kind === "income";
            return {
              id: c.id,
              name: c.name,
              icon: (
                <span className="grid size-9 place-items-center rounded-xl text-on-tile" style={{ background: color }}>
                  <Icon className="size-[16px]" strokeWidth={2} aria-hidden />
                </span>
              ),
              note: income ? `Received ${formatCount(totals.received)} ${totals.received === 1 ? "time" : "times"}, last 12 months` : `${formatCount(totals.payments)} ${totals.payments === 1 ? "payment" : "payments"}, last 12 months`,
              amount: income ? totals.moneyIn : totals.spent,
            };
          })}
        >
          <Detail line={chosen} months={data.months} ledger={ledger} />
        </Browse>
      )}
    </div>
  );
}

type Line = { c: Named & { icon: string | null; kind: string; archived: boolean }; totals: Totals; budget: number | null };

function Detail({ line, months, ledger }: { line: Line; months: Period[]; ledger: Ledger }) {
  const { c, totals, budget } = line;
  const income = c.kind === "income";
  const monthly = income ? totals.incomeMonthly : totals.monthly;
  const thisMonth = monthly.at(-1) ?? 0;
  const { Icon, color } = categoryStyle(c.icon);
  const mine = ledger.items.filter((i) => !i.t.hidden && i.t.categoryId === c.id).sort((a, b) => b.t.at - a.t.at);
  return (
    <>
      <Card id="category" title={c.name} i={3} action={<span className="grid size-11 place-items-center rounded-2xl text-on-tile" style={{ background: color }}><Icon className="size-5" strokeWidth={2} aria-hidden /></span>}>
        <Stats
          items={[
            ["This month", formatPaise(thisMonth)],
            ["Monthly average", formatPaise(monthlyAverage(monthly))],
            [income ? "Last 12 months" : "Spent, 12 months", formatPaise(income ? totals.moneyIn : totals.spent)],
            income ? ["Times received", formatCount(totals.received)] : budget !== null ? ["Budget", formatPaise(budget)] : ["Payments", formatCount(totals.payments)],
          ]}
        />
        {budget !== null && !income && (
          <p className={`rounded-xl px-4 py-3 text-[0.9375rem] ${thisMonth > budget ? "bg-sunken text-danger" : "bg-honey-soft text-ink"}`}>
            {thisMonth > budget ? `${formatPaise(thisMonth - budget)} over this month's ${formatPaise(budget)} budget.` : `${formatPaise(budget - thisMonth)} left of this month's ${formatPaise(budget)} budget.`}
          </p>
        )}
        <TrendChart label={income ? "in" : "spent"} months={months.map((p, i) => ({ start: p.start, end: p.end, spent: income ? 0 : totals.monthly[i], moneyIn: income ? totals.incomeMonthly[i] : 0, isShown: i === months.length - 1 }))} />
      </Card>
      <Card id="category-recent" title="Latest" i={4}>
        {mine.length ? <Recent items={mine.slice(0, RECENT)} total={mine.length} href={`/transactions?category=${encodeURIComponent(c.id)}`} /> : <Quiet>Nothing in {c.name} yet.</Quiet>}
      </Card>
    </>
  );
}
