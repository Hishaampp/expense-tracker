"use client";

import { useMemo } from "react";
import { AgainstBudget } from "@/components/browse/against-budget";
import { Stats } from "@/components/browse/browse";
import { categoryStyle } from "@/components/overview/category-style";
import { Card, Quiet } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";
import { formatPaise, formatPeriodTitle } from "@/lib/format/format";
import { budgetsOf } from "@/lib/insights/budgets";
import { useLedger } from "@/lib/insights/use-ledger";

/** Each budget's month, what's left, and the last 6 months against it. */
export default function BudgetsPage() {
  const ledger = useLedger();
  const b = useMemo(() => (ledger ? budgetsOf(ledger.vault, ledger.txns, ledger.now) : null), [ledger]);
  if (!ledger || !b) return null;
  const today = new Date(ledger.now.getFullYear(), ledger.now.getMonth(), ledger.now.getDate());
  const current = b.months.at(-1)!;
  const month = formatPeriodTitle(current.period, today);
  const lines = [...b.byCategory]
    .map(([id, budget]) => ({ id, budget, c: ledger.lookup.categories.get(id), spent: current.byCategory.get(id) ?? 0 }))
    .sort((x, y) => y.spent / y.budget - x.spent / x.budget);
  const { safe } = b;

  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <PageHeader title="Budgets" note={`How ${month} is going against what you set. Budgets are set on your phone.`} />
      {b.monthly === null && lines.length === 0 ? (
        <Quiet>No budgets yet. Set a monthly budget, or one per category, on your phone in Budgets.</Quiet>
      ) : (
        <>
          {b.monthly !== null && (
            <Card id="monthly" title="Monthly budget" note="Rooms kept out of the budget are left out, as on your phone. Earlier months are measured against today's budget." i={2}>
              <Stats
                items={[
                  ["Budget", formatPaise(b.monthly)],
                  [`Spent in ${month}`, formatPaise(current.monthly)],
                  [safe.kind === "over" ? "Over by" : "Left", formatPaise(safe.kind === "over" ? safe.over : safe.kind === "onTrack" ? safe.left : 0)],
                  ["Safe to spend today", safe.kind === "onTrack" ? formatPaise(safe.perDay) : "—"],
                ]}
              />
              <AgainstBudget budget={b.monthly} months={b.months.map((m) => ({ period: m.period, spent: m.monthly }))} />
            </Card>
          )}
          {lines.length > 0 && (
            <Card id="category-budgets" title="Category budgets" note={`${month}, with the last 6 months beside each.`} i={3}>
              <ul className="grid gap-2">
                {lines.map(({ id, budget, c, spent }) => {
                  const { Icon, color } = categoryStyle(c?.icon ?? null);
                  const over = spent > budget;
                  return (
                    <li key={id} className="grid grid-cols-[auto_minmax(0,1fr)] items-center gap-x-4 gap-y-3 rounded-xl px-2 py-3 transition-colors hover:bg-raised-2 sm:grid-cols-[auto_minmax(0,1fr)_11rem]">
                      <span className="grid size-10 place-items-center rounded-xl text-on-tile" style={{ background: color }}>
                        <Icon className="size-[18px]" strokeWidth={2} aria-hidden />
                      </span>
                      <div className="min-w-0">
                        <div className="flex items-baseline justify-between gap-3">
                          <p className="truncate font-semibold">{c?.name ?? "Category"}</p>
                          <p className="tabular text-[0.9375rem] font-semibold">
                            {formatPaise(Math.max(0, spent))} <span className="font-normal text-ink-muted">of {formatPaise(budget)}</span>
                          </p>
                        </div>
                        <div className="mt-2 h-2 overflow-hidden rounded-full bg-sunken">
                          <div className={`grow-x h-full origin-left rounded-full ${over ? "bg-danger" : ""}`} style={{ transform: `scaleX(${Math.max(0, Math.min(1, spent / budget))})`, background: over ? undefined : color }} />
                        </div>
                        <p className={`tabular mt-1 text-[0.8125rem] ${over ? "text-danger" : "text-ink-muted"}`}>{over ? `${formatPaise(spent - budget)} over` : `${formatPaise(budget - spent)} left`}</p>
                      </div>
                      <div className="col-span-2 sm:col-span-1">
                        <AgainstBudget compact budget={budget} months={b.months.map((m) => ({ period: m.period, spent: m.byCategory.get(id) ?? 0 }))} />
                      </div>
                    </li>
                  );
                })}
              </ul>
            </Card>
          )}
        </>
      )}
    </div>
  );
}
