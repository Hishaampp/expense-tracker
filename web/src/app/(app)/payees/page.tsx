"use client";

import { useMemo } from "react";
import { Browse, Recent, Stats } from "@/components/browse/browse";
import { TrendChart } from "@/components/overview/trend-chart";
import { Card, Quiet } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";
import { formatCount, formatDate, formatPaise } from "@/lib/format/format";
import { monthlyAverage, payeesOf, totalsFor, yearOf, type PayeeInfo, type Totals } from "@/lib/insights/browse";
import type { Period } from "@/lib/insights/period";
import { dividedRounded } from "@/lib/insights/money";
import { payeeKeyOf } from "@/lib/insights/tables";
import { useLedger, type Ledger } from "@/lib/insights/use-ledger";
import { useQueryState } from "@/lib/url-state";

const RECENT = 8;
const LISTED = 60;

/** Where the money goes: each payee's last 12 months, usual payment and latest transactions. */
export default function PayeesPage() {
  const ledger = useLedger();
  const [params, write] = useQueryState();

  const data = useMemo(() => {
    if (!ledger) return null;
    const { months } = yearOf(ledger.vault, ledger.now);
    const lines = [...payeesOf(ledger.txns).values()]
      .map((p) => ({ p, totals: totalsFor(ledger.txns, months, (t) => payeeKeyOf(t) === p.key) }))
      .filter((l) => l.totals.spent > 0)
      .sort((a, b) => b.totals.spent - a.totals.spent || a.p.name.localeCompare(b.p.name));
    return { months, lines };
  }, [ledger]);

  if (!ledger || !data) return null;
  const chosenKey = params?.get("id") ?? data.lines[0]?.p.key ?? null;
  const chosen = data.lines.find((l) => l.p.key === chosenKey) ?? data.lines[0];
  const shown = data.lines.slice(0, LISTED);
  if (chosen && !shown.includes(chosen)) shown.push(chosen);

  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <PageHeader title="Payees" note={data.lines.length > LISTED ? `Your top ${LISTED} of ${formatCount(data.lines.length)} payees, last 12 months.` : "Who you paid over the last 12 months."} />
      {!chosen ? (
        <Quiet>No payees in the last 12 months. Payees appear once payments name who was paid.</Quiet>
      ) : (
        <Browse
          label="Payees"
          chosen={chosen.p.key}
          onChoose={(id) => write({ id })}
          entries={shown.map(({ p, totals }, i) => ({
            id: p.key,
            name: p.name,
            icon: <span className="tabular grid size-8 place-items-center rounded-full bg-honey-soft text-[0.75rem] font-bold text-honey-text">{i + 1}</span>,
            note: `${formatCount(totals.payments)} ${totals.payments === 1 ? "payment" : "payments"}`,
            amount: totals.spent,
          }))}
        >
          <Detail line={chosen} months={data.months} ledger={ledger} />
        </Browse>
      )}
    </div>
  );
}

function Detail({ line, months, ledger }: { line: { p: PayeeInfo; totals: Totals }; months: Period[]; ledger: Ledger }) {
  const { p, totals } = line;
  const mine = ledger.items.filter((i) => !i.t.hidden && payeeKeyOf(i.t) === p.key).sort((a, b) => b.t.at - a.t.at);
  const category = p.categoryId ? ledger.lookup.categories.get(p.categoryId)?.name : null;
  const first = mine.at(-1);
  return (
    <>
      <Card id="payee" title={p.name} note={[p.key !== p.name.toLowerCase() ? p.key : null, category ? `Usually ${category}` : null, first ? `First paid ${formatDate(first.t.at)}` : null].filter(Boolean).join(" · ")} i={3}>
        <Stats
          items={[
            ["Spent, 12 months", formatPaise(totals.spent)],
            ["Payments", formatCount(totals.payments)],
            ["Usual payment", formatPaise(totals.payments ? dividedRounded(totals.spent, totals.payments) : 0)],
            ["Monthly average", formatPaise(monthlyAverage(totals.monthly))],
          ]}
        />
        <TrendChart months={months.map((m, i) => ({ start: m.start, end: m.end, spent: totals.monthly[i], moneyIn: 0, isShown: i === months.length - 1 }))} />
      </Card>
      <Card id="payee-recent" title="Latest" i={4}>
        <Recent items={mine.slice(0, RECENT)} total={mine.length} href={`/transactions?q=${encodeURIComponent(p.name)}`} />
      </Card>
    </>
  );
}
