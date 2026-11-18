import { formatMonthShort, formatPaise, formatPaiseCompact, formatPeriodRange } from "@/lib/format/format";
import type { Period } from "@/lib/insights/period";

/**
 * Months as bars against a budget line: honey under the budget, red over
 * it, the month in progress marked. Each bar says its numbers in words too.
 */
export function AgainstBudget({ months, budget, compact = false }: { months: { period: Period; spent: number }[]; budget: number; compact?: boolean }) {
  const top = Math.max(budget * 1.25, ...months.map((m) => m.spent)) || 1;
  const line = (budget / top) * 100;
  return (
    <div className="grid gap-2">
      <div className={`relative ${compact ? "h-16" : "h-44"}`}>
        <div className="absolute inset-x-0 border-t-2 border-dashed border-honey/60" style={{ bottom: `${line}%` }} aria-hidden>
          {!compact && <span className="tabular absolute -top-5 right-0 text-[0.75rem] font-semibold text-honey-text">Budget {formatPaiseCompact(budget)}</span>}
        </div>
        <ol className="relative flex h-full items-end gap-2 sm:gap-3">
          {months.map((m, i) => {
            const over = m.spent > budget;
            const current = i === months.length - 1;
            return (
              <li key={m.period.start.getTime()} className="flex h-full flex-1 items-end justify-center">
                <span className="sr-only">
                  {formatPeriodRange(m.period)}: {formatPaise(Math.max(0, m.spent))}, {over ? `${formatPaise(m.spent - budget)} over` : `${formatPaise(budget - m.spent)} under`}
                </span>
                <span
                  aria-hidden
                  className={`grow-y block w-full max-w-10 rounded-t-[6px] ${over ? "bg-danger" : "bg-honey"} ${current ? "" : "opacity-60"}`}
                  style={{ height: `${Math.max(m.spent > 0 ? 2 : 0, (Math.max(0, m.spent) / top) * 100)}%`, "--i": i } as React.CSSProperties}
                />
              </li>
            );
          })}
        </ol>
      </div>
      {!compact && (
        <div className="flex gap-2 text-center text-[0.75rem] sm:gap-3" aria-hidden>
          {months.map((m, i) => (
            <span key={m.period.start.getTime()} className={`flex-1 ${i === months.length - 1 ? "font-semibold text-ink" : "text-ink-faint"}`}>
              {formatMonthShort(m.period)}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}
