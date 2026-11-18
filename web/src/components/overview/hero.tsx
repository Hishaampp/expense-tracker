import { AmpleMark } from "@/components/brand/ample-mark";
import { CountUp } from "@/components/ui/count-up";
import { formatPaise, formatPeriodTitle } from "@/lib/format/format";
import type { Overview } from "@/lib/insights/overview";
import { Delta } from "./delta";

/** The month at a glance: what went out, what is left, and what is safe to spend. */
export function OverviewHero({ o, today }: { o: Overview; today: Date }) {
  const month = formatPeriodTitle(o.period, today);
  const previous = formatPeriodTitle(o.previous, today);
  const { safe } = o;
  return (
    <section
      aria-label={`${month} at a glance`}
      className="rise relative overflow-hidden rounded-[1.75rem] bg-hero p-7 text-on-hero shadow-[var(--shadow-far)] sm:p-10"
      style={{ "--i": 2 } as React.CSSProperties}
    >
      <AmpleMark size={300} sway title={null} honeyOpacity={0.14} className="pointer-events-none absolute -right-16 -bottom-20 text-on-hero/[0.07]" />
      <div className="relative grid gap-8 lg:grid-cols-[minmax(0,1.25fr)_minmax(0,1fr)] lg:items-end">
        <div className="grid gap-2">
          <p className="text-[0.9375rem] font-semibold text-on-hero-muted">
            {o.isCurrent ? `Spent so far in ${month}` : `Spent in ${month}`}
          </p>
          <p className="font-display text-[3rem] leading-none tracking-[-0.025em] sm:text-[4.25rem]">
            <CountUp value={o.summary.spent} format={formatPaise} />
          </p>
          <div className="mt-2">
            <Delta
              now={o.summary.spent}
              before={o.isCurrent ? spentByNowIn(o) : o.previousSummary.spent}
              versus={o.isCurrent ? `this point in ${previous}` : previous}
              goodWhenLower
              tone="hero"
            />
          </div>
        </div>

        <div className="grid gap-5">
          {o.showsBalance && (
            <div className="grid gap-1">
              <p className="text-[0.875rem] text-on-hero-muted">{o.balance < 0 ? "Over what came in" : "Left this month"}</p>
              <p className={`font-display text-[1.875rem] leading-tight ${o.balance < 0 ? "text-hero-danger" : "text-honey"}`}>
                <CountUp value={Math.abs(o.balance)} format={formatPaise} />
              </p>
              <p className="tabular text-[0.8125rem] text-on-hero-muted">
                {formatPaise(o.summary.moneyIn)} came in{o.carried !== 0 && <>, {formatPaise(Math.abs(o.carried))} {o.carried > 0 ? "carried over" : "short from before"}</>}
              </p>
            </div>
          )}
          {safe.kind !== "none" && (
            <div className="grid gap-2 rounded-2xl bg-on-hero/[0.06] p-4">
              <div className="flex items-baseline justify-between gap-3">
                <p className="text-[0.875rem] font-semibold">{safe.kind === "over" ? "Over budget" : "Safe to spend today"}</p>
                <p className={`tabular font-display text-[1.375rem] ${safe.kind === "over" ? "text-hero-danger" : "text-honey"}`}>
                  {formatPaise(safe.kind === "over" ? safe.over : safe.perDay)}
                </p>
              </div>
              <div
                className="h-1.5 overflow-hidden rounded-full bg-on-hero/10"
                role="meter"
                aria-label="Budget used"
                aria-valuemin={0}
                aria-valuemax={safe.budget}
                aria-valuenow={Math.max(0, Math.min(safe.spent, safe.budget))}
              >
                <div
                  className={`grow-x h-full origin-left rounded-full ${safe.kind === "over" ? "bg-hero-danger" : "bg-honey"}`}
                  style={{ transform: `scaleX(${Math.max(0, Math.min(1, safe.spent / safe.budget))})` }}
                />
              </div>
              <p className="tabular text-[0.8125rem] text-on-hero-muted">
                {safe.kind === "over"
                  ? `${formatPaise(safe.spent)} of a ${formatPaise(safe.budget)} budget`
                  : `${formatPaise(safe.left)} left of ${formatPaise(safe.budget)} · ${safe.daysLeft} ${safe.daysLeft === 1 ? "day" : "days"} to go`}
              </p>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}

/** Last month's spending up to the same day, so a month in progress compares fairly. */
function spentByNowIn(o: Overview): number {
  const sameDay = o.days.findIndex((d) => d.future);
  const counted = sameDay === -1 ? o.days.length : sameDay;
  return o.previousDays.slice(0, counted).reduce((sum, d) => sum + d.spent, 0);
}
