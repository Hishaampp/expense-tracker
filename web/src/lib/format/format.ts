const inr = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 2,
  minimumFractionDigits: 2,
});

/** ₹ with Indian grouping (₹1,23,456.50); paise shown only when present. */
export function formatPaise(paise: number): string {
  const rupees = paise / 100;
  return inr.format(rupees).replace(/\.00$/, "");
}

const count = new Intl.NumberFormat("en-IN");

/** A count with Indian grouping. */
export const formatCount = (n: number) => count.format(n);

/** "4:32 pm, 17 Nov" style, in the viewer's time zone. */
export function formatWhen(ms: number): string {
  return new Intl.DateTimeFormat("en-IN", {
    hour: "numeric",
    minute: "2-digit",
    day: "numeric",
    month: "short",
  }).format(ms);
}

/** "Nov 2024". */
export function formatMonth(ms: number): string {
  return new Intl.DateTimeFormat("en-IN", { month: "short", year: "numeric" }).format(ms);
}

/** ₹ in a few characters for chart axes: ₹950, ₹12.5k, ₹1.2L, ₹3.4Cr. */
export function formatPaiseCompact(paise: number): string {
  const sign = paise < 0 ? "−" : "";
  const r = Math.abs(paise) / 100;
  const trim = (n: number) => (n >= 100 ? Math.round(n).toString() : n.toFixed(1).replace(/\.0$/, ""));
  if (r >= 1e7) return `${sign}₹${trim(r / 1e7)}Cr`;
  if (r >= 1e5) return `${sign}₹${trim(r / 1e5)}L`;
  if (r >= 1e3) return `${sign}₹${trim(r / 1e3)}k`;
  return `${sign}₹${Math.round(r)}`;
}

// The app's naming (lib/formatting/date_format.dart): a month that starts
// mid-month is named after the month it ends in.
const named = (p: { start: Date; end: Date }) =>
  p.start.getDate() === 1 ? p.start : new Date(p.end.getFullYear(), p.end.getMonth(), p.end.getDate() - 1);

/** "November", with the year when it isn't [today]'s. */
export function formatPeriodTitle(p: { start: Date; end: Date }, today: Date): string {
  const d = named(p);
  return new Intl.DateTimeFormat("en-IN", d.getFullYear() === today.getFullYear() ? { month: "long" } : { month: "long", year: "numeric" }).format(d);
}

/** "November 2026", or "25 Oct – 24 Nov 2026" for a month starting on another day. */
export function formatPeriodRange(p: { start: Date; end: Date }): string {
  if (p.start.getDate() === 1) return new Intl.DateTimeFormat("en-IN", { month: "long", year: "numeric" }).format(p.start);
  const last = named(p);
  const from = new Intl.DateTimeFormat("en-IN", { day: "numeric", month: "short" }).format(p.start);
  const to = new Intl.DateTimeFormat("en-IN", { day: "numeric", month: "short", year: "numeric" }).format(last);
  return `${from} – ${to}`;
}

/** "Nov", for a chart axis. */
export function formatMonthShort(p: { start: Date; end: Date }): string {
  return new Intl.DateTimeFormat("en-IN", { month: "short" }).format(named(p));
}

/** "Tue, 3 Nov". */
export function formatDay(d: Date): string {
  return new Intl.DateTimeFormat("en-IN", { weekday: "short", day: "numeric", month: "short" }).format(d);
}

const shortDate = new Intl.DateTimeFormat("en-IN", { day: "numeric", month: "short", year: "numeric" });
const clock = new Intl.DateTimeFormat("en-IN", { hour: "numeric", minute: "2-digit" });
const fullWhen = new Intl.DateTimeFormat("en-IN", { weekday: "long", day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit" });

/** "17 Nov 2026". */
export const formatDate = (at: number | Date) => shortDate.format(at);

/** "4:32 pm". */
export const formatTime = (at: number | Date) => clock.format(at);

/** "Tuesday, 17 November 2026 at 4:32 pm". */
export const formatFullWhen = (at: number | Date) => fullWhen.format(at);
