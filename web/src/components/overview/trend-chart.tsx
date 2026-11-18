"use client";

import { useState } from "react";
import { formatMonthShort, formatPaise, formatPaiseCompact, formatPeriodRange } from "@/lib/format/format";
import type { TrendMonth } from "@/lib/insights/overview";

/** Rounds [max] up to a readable top for the scale (1, 2, 2.5 or 5 × 10ⁿ). */
function niceTop(max: number): number {
  if (max <= 0) return 100_000;
  const pow = 10 ** Math.floor(Math.log10(max));
  for (const step of [1, 2, 2.5, 5, 10]) if (step * pow >= max) return step * pow;
  return 10 * pow;
}

/** Twelve months of spending (honey) and money in (green), the shown month marked. */
export function TrendChart({ months, onPick }: { months: TrendMonth[]; onPick: (index: number) => void }) {
  const [focus, setFocus] = useState<number | null>(null);
  const showIncome = months.some((m) => m.moneyIn > 0);
  const top = niceTop(Math.max(...months.map((m) => Math.max(m.spent, showIncome ? m.moneyIn : 0))));
  const ticks = [top, top / 2, 0];
  const active = focus ?? months.length - 1;
  const a = months[active];

  return (
    <div className="grid gap-5">
      <div className="flex flex-wrap items-end justify-between gap-x-6 gap-y-2" aria-live="polite">
        <div>
          <p className="text-[0.875rem] text-ink-muted">{formatPeriodRange(a)}</p>
          <p className="tabular font-display text-[1.5rem]">
            {formatPaise(Math.max(0, a.spent))} <span className="font-sans text-[0.9375rem] text-ink-muted">spent</span>
            {showIncome && (
              <>
                {" · "}
                <span className="text-income">{formatPaise(a.moneyIn)}</span> <span className="font-sans text-[0.9375rem] text-ink-muted">in</span>
              </>
            )}
          </p>
        </div>
        <div className="flex items-center gap-4 text-[0.8125rem] text-ink-muted" aria-hidden>
          <span className="inline-flex items-center gap-1.5">
            <span className="size-2.5 rounded-[3px] bg-honey" /> Spent
          </span>
          {showIncome && (
            <span className="inline-flex items-center gap-1.5">
              <span className="size-2.5 rounded-[3px] bg-income" /> Money in
            </span>
          )}
        </div>
      </div>

      <div className="grid grid-cols-[auto_minmax(0,1fr)] gap-x-3">
        <div className="relative h-56 w-12 text-right text-[0.75rem] text-ink-faint" aria-hidden>
          {ticks.map((t, i) => (
            <span key={t} className="tabular absolute right-0 -translate-y-1/2" style={{ top: `${(i / (ticks.length - 1)) * 100}%` }}>
              {formatPaiseCompact(t)}
            </span>
          ))}
        </div>
        <div className="relative h-56">
          {ticks.map((t, i) => (
            <div key={t} className={`absolute inset-x-0 border-t ${i === ticks.length - 1 ? "border-line-strong/50" : "border-dashed border-line"}`} style={{ top: `${(i / (ticks.length - 1)) * 100}%` }} aria-hidden />
          ))}
          <ol className="relative grid h-full grid-cols-12 gap-1 sm:gap-2" onMouseLeave={() => setFocus(null)}>
            {months.map((m, i) => {
              const spentH = (Math.max(0, m.spent) / top) * 100;
              const inH = (m.moneyIn / top) * 100;
              const on = i === active;
              return (
                <li key={m.start.getTime()} className="h-full">
                  <button
                    type="button"
                    onMouseEnter={() => setFocus(i)}
                    onFocus={() => setFocus(i)}
                    onBlur={() => setFocus(null)}
                    onClick={() => onPick(i)}
                    aria-label={`${formatPeriodRange(m)}: ${formatPaise(Math.max(0, m.spent))} spent${showIncome ? `, ${formatPaise(m.moneyIn)} in` : ""}. Show this month.`}
                    aria-current={m.isShown ? "date" : undefined}
                    className={`group flex h-full w-full items-end justify-center gap-[3px] rounded-lg px-0.5 transition-colors ${on ? "bg-raised-2" : "hover:bg-raised-2/60"}`}
                  >
                    <span
                      className={`grow-y block w-full max-w-5 rounded-t-[5px] transition-opacity ${m.isShown ? "bg-honey" : "bg-honey/55 group-hover:bg-honey/80"}`}
                      style={{ height: `${spentH}%`, minHeight: m.spent > 0 ? 3 : 0, "--i": i } as React.CSSProperties}
                    />
                    {showIncome && (
                      <span
                        className={`grow-y block w-full max-w-2.5 rounded-t-[4px] ${m.isShown ? "bg-income" : "bg-income/50 group-hover:bg-income/75"}`}
                        style={{ height: `${inH}%`, minHeight: m.moneyIn > 0 ? 3 : 0, "--i": i } as React.CSSProperties}
                      />
                    )}
                  </button>
                </li>
              );
            })}
          </ol>
        </div>
        <span aria-hidden />
        <div className="mt-2 grid grid-cols-12 gap-1 text-center text-[0.75rem] sm:gap-2" aria-hidden>
          {months.map((m, i) => (
            <span key={m.start.getTime()} className={m.isShown ? "font-semibold text-ink" : i === active ? "text-ink" : "text-ink-faint"}>
              <span className="sm:hidden">{formatMonthShort(m).charAt(0)}</span>
              <span className="hidden sm:inline">{formatMonthShort(m)}</span>
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
