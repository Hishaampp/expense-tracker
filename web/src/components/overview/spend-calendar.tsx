import { formatDay, formatPaise } from "@/lib/format/format";
import type { HeatDay } from "@/lib/insights/overview";

const WEEKDAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

/**
 * How strongly to fill a day: five steps against the month's biggest day,
 * on a square-root scale so one large payment (rent) doesn't wash out the
 * everyday ones.
 */
export function level(spent: number, max: number): number {
  if (spent <= 0 || max <= 0) return 0;
  return Math.min(4, Math.max(1, Math.ceil(Math.sqrt(spent / max) * 4)));
}

const FILL = ["var(--sunken)", "color-mix(in oklab, var(--honey) 22%, var(--sunken))", "color-mix(in oklab, var(--honey) 45%, var(--sunken))", "color-mix(in oklab, var(--honey) 72%, var(--sunken))", "var(--honey)"];

/** Each day of the month, filled by what it cost; days still to come are outlined. */
export function SpendCalendar({ days }: { days: HeatDay[] }) {
  const max = Math.max(0, ...days.map((d) => d.spent));
  const lead = days.length ? (days[0].date.getDay() + 6) % 7 : 0;
  const biggest = days.find((d) => d.spent === max && max > 0);
  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-7 gap-1.5 sm:gap-2">
        {WEEKDAYS.map((w) => (
          <span key={w} className="pb-1 text-center text-[0.75rem] font-semibold text-ink-faint" aria-hidden>
            {w}
          </span>
        ))}
        {Array.from({ length: lead }, (_, i) => (
          <span key={`lead-${i}`} aria-hidden />
        ))}
        {days.map((d, i) => {
          const l = level(d.spent, max);
          const label = `${formatDay(d.date)}: ${d.future ? "still to come" : d.spent > 0 ? formatPaise(d.spent) : "nothing spent"}`;
          return (
            <div
              key={d.date.getTime()}
              title={label}
              aria-label={label}
              role="img"
              className={`rise relative aspect-square rounded-lg sm:aspect-auto sm:h-14 ${d.future ? "border border-dashed border-line" : ""}`}
              style={{ background: d.future ? "transparent" : FILL[l], "--i": Math.min(i, 20) * 0.25 } as React.CSSProperties}
            >
              <span className={`tabular absolute top-1 left-1.5 text-[0.6875rem] font-semibold ${l >= 3 ? "text-on-honey" : "text-ink-faint"}`}>{d.date.getDate()}</span>
            </div>
          );
        })}
      </div>
      <div className="flex flex-wrap items-center justify-between gap-3 text-[0.8125rem] text-ink-muted">
        <p className="tabular">{biggest ? <>Biggest day: {formatDay(biggest.date)}, {formatPaise(biggest.spent)}</> : "No spending yet"}</p>
        <div className="flex items-center gap-1.5" aria-hidden>
          Less
          {FILL.map((f) => (
            <span key={f} className="size-3 rounded-[3px]" style={{ background: f }} />
          ))}
          More
        </div>
      </div>
    </div>
  );
}
