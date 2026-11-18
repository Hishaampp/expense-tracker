"use client";

import { Inbox } from "lucide-react";
import { useMemo, useState } from "react";
import { CategoryBreakdown } from "@/components/overview/category-breakdown";
import { OverviewHero } from "@/components/overview/hero";
import { KeyNumbers } from "@/components/overview/key-numbers";
import { PeriodPicker } from "@/components/overview/period-picker";
import { SpendCalendar } from "@/components/overview/spend-calendar";
import { TopPayees } from "@/components/overview/top-payees";
import { TrendChart } from "@/components/overview/trend-chart";
import { Card, Quiet } from "@/components/ui/card";
import { formatCount, formatPeriodTitle } from "@/lib/format/format";
import { overview, transactionsOf, TREND_MONTHS } from "@/lib/insights/overview";
import { useVault } from "@/lib/vault/vault-context";

/** How far back the picker goes. */
const OLDEST = -35;

function greeting(hour: number) {
  return hour < 5 ? "Good evening." : hour < 12 ? "Good morning." : hour < 17 ? "Good afternoon." : "Good evening.";
}

export default function OverviewPage() {
  const { state } = useVault();
  const vault = state.status === "open" ? state.vault : null;
  const [offset, setOffset] = useState(0);
  // "Now" is fixed while the page is open, so the numbers don't shift under the reader.
  const [now] = useState(() => new Date());
  const txns = useMemo(() => (vault ? transactionsOf(vault) : []), [vault]);
  const o = useMemo(() => (vault ? overview(vault, now, offset, txns) : null), [vault, now, offset, txns]);
  if (!vault || !o) return null;

  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const month = formatPeriodTitle(o.period, today);
  const empty = o.summary.spent === 0 && o.summary.moneyIn === 0 && o.payments === 0;

  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <header className="flex flex-wrap items-end justify-between gap-x-6 gap-y-4">
        <div className="grid gap-2">
          <h1 className="rise font-display text-[2.4rem] leading-[1.05] tracking-[-0.02em] sm:text-[3rem]">{greeting(now.getHours())}</h1>
          <p className="rise text-[1.0625rem] text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
            {o.isCurrent ? "Here's how this month is going." : `Looking back at ${month}.`}
          </p>
        </div>
        <div className="rise" style={{ "--i": 1 } as React.CSSProperties}>
          <PeriodPicker period={o.period} offset={offset} oldest={OLDEST} onChange={setOffset} />
        </div>
      </header>

      <OverviewHero o={o} today={today} />

      {o.needsReview > 0 && (
        <p className="rise flex items-center gap-3 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] text-ink" style={{ "--i": 3 } as React.CSSProperties}>
          <Inbox className="size-[18px] shrink-0 text-honey-text" aria-hidden />
          {formatCount(o.needsReview)} captured {o.needsReview === 1 ? "payment is" : "payments are"} waiting for a category. Sort them on your phone, in Review.
        </p>
      )}

      <KeyNumbers o={o} today={today} />

      <Card id="trend" title="The last 12 months" note="Choose a month to see it here." i={7}>
        <TrendChart months={o.trend} onPick={(index) => setOffset(Math.max(OLDEST, offset - (TREND_MONTHS - 1 - index)))} />
      </Card>

      <div className="grid gap-8 lg:grid-cols-[minmax(0,1.35fr)_minmax(0,1fr)]">
        <Card id="categories" title="Where it went" note={o.categories.some((c) => c.budget !== null) ? "Each category against its budget, where one is set." : undefined} i={8}>
          {o.categories.length ? <CategoryBreakdown lines={o.categories} total={o.summary.spent} /> : <Quiet>{empty ? `Nothing recorded in ${month}.` : `No spending in ${month}.`}</Quiet>}
        </Card>
        <Card id="payees" title="Top payees" i={9}>
          {o.payees.length ? <TopPayees lines={o.payees} /> : <Quiet>No payees in {month}.</Quiet>}
        </Card>
      </div>

      <Card id="calendar" title="Day by day" note={`What each day of ${month} cost.`} i={10}>
        <SpendCalendar days={o.days} />
      </Card>

      {vault.unreadable > 0 && (
        <p className="rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] text-ink">
          {formatCount(vault.unreadable)} records couldn&apos;t be opened with this code, so they&apos;re left out. They may come from an older sync key.
        </p>
      )}
    </div>
  );
}
