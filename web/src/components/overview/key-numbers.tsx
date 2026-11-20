import { ArrowDownLeft, CalendarDays, ReceiptText, Scale } from "lucide-react";
import { CountUp } from "@/components/ui/count-up";
import { formatCount, formatPaise, formatPeriodTitle } from "@/lib/format/format";
import { dividedRounded } from "@/lib/insights/money";
import type { Overview } from "@/lib/insights/overview";
import { Delta } from "./delta";

/** Money in, what the month left, the daily average and the payments, each against last month. */
export function KeyNumbers({ o, today }: { o: Overview; today: Date }) {
  const previous = formatPeriodTitle(o.previous, today);
  const net = o.summary.moneyIn - o.summary.spent;
  const previousNet = o.previousSummary.moneyIn - o.previousSummary.spent;
  const tiles = [
    {
      icon: ArrowDownLeft,
      label: "Money in",
      value: <CountUp value={o.summary.moneyIn} format={formatPaise} />,
      delta: <Delta now={o.summary.moneyIn} before={o.previousSummary.moneyIn} versus={previous} goodWhenLower={false} />,
    },
    {
      icon: Scale,
      label: net < 0 ? "Spent more than came in" : "Kept this month",
      value: <CountUp value={Math.abs(net)} format={formatPaise} />,
      delta: <Delta now={net} before={previousNet} versus={previous} goodWhenLower={false} />,
    },
    {
      icon: CalendarDays,
      label: o.isCurrent ? `Daily average, ${o.daysCounted} ${o.daysCounted === 1 ? "day" : "days"}` : "Daily average",
      value: <CountUp value={o.dailyAverage} format={formatPaise} />,
      delta: <Delta now={o.dailyAverage} before={o.previousDailyAverage} versus={previous} goodWhenLower />,
    },
    {
      icon: ReceiptText,
      label: "Payments",
      value: <CountUp value={o.payments} format={formatCount} />,
      delta: (
        <p className="tabular text-[0.8125rem] text-ink-muted">
          {o.payments ? `${formatPaise(dividedRounded(o.summary.spent, o.payments))} on average` : "None yet"}
        </p>
      ),
    },
  ];
  return (
    <section aria-label="Key numbers" className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
      {tiles.map(({ icon: Icon, label, value, delta }, i) => (
        <div
          key={i}
          className="rise grid content-start gap-3 rounded-[1.25rem] border border-line bg-raised p-5 transition-colors hover:bg-raised-2"
          style={{ "--i": 3 + i } as React.CSSProperties}
        >
          <div className="flex items-center gap-3">
            <span className="grid size-9 place-items-center rounded-xl bg-honey-soft text-honey-text">
              <Icon className="size-[17px]" strokeWidth={1.85} aria-hidden />
            </span>
            <p className="text-[0.875rem] font-semibold text-ink-muted">{label}</p>
          </div>
          <p className="font-display text-[1.75rem] leading-none tracking-[-0.015em]">{value}</p>
          {delta}
        </div>
      ))}
    </section>
  );
}
