"use client";

import { useState } from "react";
import { formatPaise } from "@/lib/format/format";
import type { CategoryLine } from "@/lib/insights/overview";
import { categoryStyle } from "./category-style";

const SHOWN = 7;

/** A donut of where the month went, and each category against its budget. */
export function CategoryBreakdown({ lines, total }: { lines: CategoryLine[]; total: number }) {
  const [hover, setHover] = useState<number | null>(null);
  const shown = lines.slice(0, SHOWN);
  const rest = lines.slice(SHOWN).reduce((sum, l) => sum + l.spent, 0);
  const slices = [...shown.map((l) => ({ share: l.share, color: categoryStyle(l.icon).color })), ...(rest > 0 ? [{ share: rest / total, color: "var(--line-strong)" }] : [])];

  const r = 42;
  const circumference = 2 * Math.PI * r;
  const gap = slices.length > 1 ? 1.4 : 0;
  let start = 0;
  const focused = hover !== null ? shown[hover] : null;

  return (
    <div className="grid items-center gap-8 md:grid-cols-[13rem_minmax(0,1fr)]">
      <div className="relative mx-auto size-52">
        <svg viewBox="0 0 100 100" className="size-full -rotate-90" aria-hidden>
          <circle cx="50" cy="50" r={r} fill="none" stroke="var(--sunken)" strokeWidth="11" />
          {slices.map((s, i) => {
            const length = Math.max(0, s.share * circumference - gap);
            const el = (
              <circle
                key={i}
                cx="50"
                cy="50"
                r={r}
                fill="none"
                stroke={s.color}
                strokeWidth={hover === i ? 13 : 11}
                strokeDasharray={`${length} ${circumference}`}
                strokeDashoffset={-start}
                className="transition-[stroke-width,opacity] duration-300"
                style={{ opacity: hover === null || hover === i ? 1 : 0.35, "--i": i } as React.CSSProperties}
              />
            );
            start += s.share * circumference;
            return el;
          })}
        </svg>
        <div className="absolute inset-0 grid place-content-center text-center" aria-live="polite">
          <p className="text-[0.8125rem] text-ink-muted">{focused ? focused.name : "Spent"}</p>
          <p className="tabular font-display text-[1.375rem] leading-tight">{formatPaise(focused ? focused.spent : total)}</p>
          {focused && <p className="tabular text-[0.8125rem] text-ink-muted">{Math.round(focused.share * 100)}%</p>}
        </div>
      </div>

      <ul className="grid gap-1" onMouseLeave={() => setHover(null)}>
        {shown.map((l, i) => {
          const { Icon, color } = categoryStyle(l.icon);
          const over = l.budget !== null && l.budgetSpent > l.budget;
          return (
            <li key={l.id ?? "none"} onMouseEnter={() => setHover(i)} className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-x-3 rounded-xl px-2 py-2 transition-colors hover:bg-raised-2">
              <span className="grid size-9 place-items-center rounded-xl text-on-tile" style={{ background: color }}>
                <Icon className="size-[17px]" strokeWidth={2} aria-hidden />
              </span>
              <div className="min-w-0">
                <div className="flex items-baseline justify-between gap-3">
                  <p className="truncate text-[0.9375rem] font-semibold">{l.name}</p>
                  <p className="tabular text-[0.8125rem] text-ink-muted">{Math.round(l.share * 100)}%</p>
                </div>
                {l.budget !== null ? (
                  <>
                    <div className="mt-1.5 h-1.5 overflow-hidden rounded-full bg-sunken">
                      <div className={`grow-x h-full origin-left rounded-full ${over ? "bg-danger" : ""}`} style={{ transform: `scaleX(${Math.min(1, Math.max(0, l.budgetSpent / l.budget))})`, background: over ? undefined : color }} />
                    </div>
                    <p className={`tabular mt-1 text-[0.75rem] ${over ? "text-danger" : "text-ink-muted"}`}>
                      {over ? `${formatPaise(l.budgetSpent - l.budget)} over its ${formatPaise(l.budget)} budget` : `${formatPaise(l.budget - l.budgetSpent)} left of ${formatPaise(l.budget)}`}
                    </p>
                  </>
                ) : (
                  <div className="mt-1.5 h-1.5 overflow-hidden rounded-full bg-sunken">
                    <div className="grow-x h-full origin-left rounded-full" style={{ transform: `scaleX(${l.share})`, background: color }} />
                  </div>
                )}
              </div>
              <p className="tabular text-[0.9375rem] font-semibold">{formatPaise(l.spent)}</p>
            </li>
          );
        })}
        {rest > 0 && (
          <li className="flex items-center justify-between px-2 pt-2 text-[0.875rem] text-ink-muted">
            <span>
              {lines.length - SHOWN} more {lines.length - SHOWN === 1 ? "category" : "categories"}
            </span>
            <span className="tabular">{formatPaise(rest)}</span>
          </li>
        )}
      </ul>
    </div>
  );
}
