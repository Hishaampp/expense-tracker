import { formatPaise } from "@/lib/format/format";
import type { Kind } from "@/lib/insights/money";

/** An amount as the app shows it: money in and refunds with a +, transfers muted. */
export function Amount({ kind, paise, className = "" }: { kind: Kind; paise: number; className?: string }) {
  const tone = kind === "income" || kind === "refund" ? "text-income" : kind === "transfer" ? "text-ink-muted" : "text-ink";
  const sign = kind === "income" || kind === "refund" ? "+" : "";
  return <span className={`tabular font-semibold ${tone} ${className}`}>{sign + formatPaise(paise)}</span>;
}

export const KIND_LABEL: Record<Kind, string> = { expense: "Payment", income: "Money in", refund: "Refund", transfer: "Transfer" };
export const ORIGIN_LABEL: Record<string, string> = { auto: "Captured", manual: "Typed in" };
