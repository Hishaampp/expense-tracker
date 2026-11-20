/**
 * One budgeting month, ported from the app's lib/core/month_period.dart:
 * from the user's "month starts on day N" up to, not including, the same
 * day of the next month. Dates are local calendar days at midnight; when a
 * month is shorter than N, the period starts on its last day.
 */
export type Period = { start: Date; end: Date; startDay: number };

/** Largest start day the app lets the user choose. */
export const MAX_START_DAY = 28;

const DAY_MS = 86_400_000;

// Date normalises month -1 and 12 into the neighbouring year, as Dart does.
function startIn(year: number, month0: number, startDay: number): Date {
  const daysInMonth = new Date(year, month0 + 1, 0).getDate();
  return new Date(year, month0, Math.min(startDay, daysInMonth));
}

/** The period containing [local], for months starting on [startDay]. */
export function periodContaining(local: Date, startDay = 1): Period {
  const day = Math.min(31, Math.max(1, Math.trunc(startDay)));
  const y = local.getFullYear();
  const m = local.getMonth();
  const thisStart = startIn(y, m, day);
  const date = new Date(y, m, local.getDate());
  if (date < thisStart) return { start: startIn(y, m - 1, day), end: thisStart, startDay: day };
  return { start: thisStart, end: startIn(y, m + 1, day), startDay: day };
}

/** The period [months] after [p] (before it, when negative). */
export function shifted(p: Period, months: number): Period {
  let out = p;
  for (let i = 0; i < Math.abs(months); i++) {
    out =
      months > 0
        ? periodContaining(out.end, out.startDay)
        : periodContaining(new Date(out.start.getTime() - DAY_MS), out.startDay);
  }
  return out;
}

/** Whether [ms] (a moment) falls inside [p]. */
export function contains(p: Period, ms: number): boolean {
  return ms >= p.start.getTime() && ms < p.end.getTime();
}

const utcDay = (d: Date) => Date.UTC(d.getFullYear(), d.getMonth(), d.getDate());

/** Days of [p] up to and including [local]: all of a past period, 0 for a future one. */
export function daysElapsedOn(p: Period, local: Date): number {
  const day = utcDay(local);
  const from = utcDay(p.start);
  const to = utcDay(p.end);
  if (day < from) return 0;
  const last = day < to ? day : to - DAY_MS;
  return Math.round((last - from) / DAY_MS) + 1;
}

/** Days from [local] to the end of [p], counting [local]; 0 outside it. */
export function daysLeftIncluding(p: Period, local: Date): number {
  if (!contains(p, local.getTime())) return 0;
  return Math.round((utcDay(p.end) - utcDay(local)) / DAY_MS);
}

/** Days in [p]. */
export function lengthInDays(p: Period): number {
  return Math.round((utcDay(p.end) - utcDay(p.start)) / DAY_MS);
}

/** The month start day from the synced settings (1–28, default 1). */
export function startDayFrom(settings: Map<string, Record<string, unknown>>): number {
  const raw = settings.get("month_start_day")?.value;
  const n = Number.parseInt(String(raw ?? ""), 10);
  return Number.isFinite(n) ? Math.min(MAX_START_DAY, Math.max(1, n)) : 1;
}
