"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import { formatPeriodRange } from "@/lib/format/format";
import type { Period } from "@/lib/insights/period";

/** The month shown: back and forward a month at a time, back to now in one tap. */
export function PeriodPicker({
  period,
  offset,
  oldest,
  onChange,
}: {
  period: Period;
  offset: number;
  oldest: number;
  onChange: (offset: number) => void;
}) {
  const button =
    "grid size-10 place-items-center rounded-full text-ink-muted transition-colors hover:bg-raised-2 hover:text-ink disabled:pointer-events-none disabled:opacity-35";
  return (
    <div className="flex items-center gap-2">
      <div className="flex items-center gap-1 rounded-full border border-line bg-raised p-1 shadow-[var(--shadow-near)]">
        <button type="button" className={button} onClick={() => onChange(offset - 1)} disabled={offset <= oldest} aria-label="Previous month">
          <ChevronLeft className="size-[18px]" aria-hidden />
        </button>
        <p className="tabular min-w-[9.5rem] text-center text-[0.9375rem] font-semibold" aria-live="polite">
          {formatPeriodRange(period)}
        </p>
        <button type="button" className={button} onClick={() => onChange(offset + 1)} disabled={offset >= 0} aria-label="Next month">
          <ChevronRight className="size-[18px]" aria-hidden />
        </button>
      </div>
      {offset < 0 && (
        <button
          type="button"
          onClick={() => onChange(0)}
          className="h-10 rounded-full px-4 text-[0.875rem] font-semibold text-honey-text transition-colors hover:bg-honey-soft"
        >
          This month
        </button>
      )}
    </div>
  );
}
