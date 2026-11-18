import { formatDay, formatPaise, formatPaiseCompact } from "@/lib/format/format";

/** Spending per day as bars, with the biggest day labelled; days with nothing stay as a faint stub. */
export function DayBars({ days }: { days: { date: Date; spent: number }[] }) {
  const max = Math.max(0, ...days.map((d) => d.spent));
  const step = Math.max(1, Math.ceil(days.length / 10));
  return (
    <div className="grid gap-2">
      <ol className="flex h-44 items-end gap-[3px]" aria-label="Spending per day">
        {days.map((d, i) => (
          <li key={d.date.getTime()} className="flex h-full min-w-0 flex-1 items-end" title={`${formatDay(d.date)}: ${formatPaise(Math.max(0, d.spent))}`}>
            <span className="sr-only">
              {formatDay(d.date)}: {formatPaise(Math.max(0, d.spent))}
            </span>
            <span
              aria-hidden
              className={`grow-y block w-full rounded-t-[4px] ${d.spent > 0 ? "bg-honey" : "bg-line"}`}
              style={{ height: d.spent > 0 && max > 0 ? `${Math.max(3, (d.spent / max) * 100)}%` : "3px", "--i": Math.min(i, 30) } as React.CSSProperties}
            />
          </li>
        ))}
      </ol>
      <div className="flex justify-between text-[0.75rem] text-ink-faint" aria-hidden>
        {days.filter((_, i) => i % step === 0).map((d) => (
          <span key={d.date.getTime()}>{d.date.getDate()}</span>
        ))}
      </div>
      {max > 0 && <p className="tabular text-[0.8125rem] text-ink-muted">Biggest day {formatPaiseCompact(max)}</p>}
    </div>
  );
}
