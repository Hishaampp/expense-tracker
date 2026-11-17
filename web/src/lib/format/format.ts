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
