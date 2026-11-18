/**
 * Per-category and per-payee totals for the Categories and Payees pages:
 * the last 12 budgeting months, the app's rules (hidden left out, refunds
 * reduce spending, transfers ignored).
 */
import type { Vault } from "@/lib/vault/vault";
import { dividedRounded, inPeriod, summarise, type Txn } from "./money";
import { periodContaining, shifted, startDayFrom, type Period } from "./period";
import { payeeKeyOf } from "./tables";

export const YEAR_MONTHS = 12;

/** The last 12 budgeting months, oldest first, and their span. */
export function yearOf(vault: Vault, now: Date): { months: Period[]; from: number; to: number } {
  const current = periodContaining(new Date(now.getFullYear(), now.getMonth(), now.getDate()), startDayFrom(vault.tables.settings));
  const months = Array.from({ length: YEAR_MONTHS }, (_, i) => shifted(current, i - (YEAR_MONTHS - 1)));
  return { months, from: months[0].start.getTime(), to: current.end.getTime() };
}

export type Totals = { spent: number; moneyIn: number; payments: number; received: number; monthly: number[]; incomeMonthly: number[] };

/** Totals over [months] for the transactions [pick] keeps. */
export function totalsFor(txns: readonly Txn[], months: Period[], pick: (t: Txn) => boolean): Totals {
  const mine = txns.filter((t) => !t.hidden && pick(t));
  const monthly: number[] = [];
  const incomeMonthly: number[] = [];
  let payments = 0;
  let received = 0;
  for (const p of months) {
    const these = inPeriod(mine, p);
    const s = summarise(these);
    monthly.push(s.spent);
    incomeMonthly.push(s.moneyIn);
    payments += these.filter((t) => t.kind === "expense").length;
    received += these.filter((t) => t.kind === "income").length;
  }
  return { spent: monthly.reduce((a, b) => a + b, 0), moneyIn: incomeMonthly.reduce((a, b) => a + b, 0), payments, received, monthly, incomeMonthly };
}

/** Average per month over the months that had any spending (rounded like the app). */
export function monthlyAverage(monthly: number[]): number {
  const active = monthly.filter((m) => m !== 0);
  return active.length ? dividedRounded(active.reduce((a, b) => a + b, 0), active.length) : 0;
}

export type PayeeInfo = { key: string; name: string; categoryId: string | null };

/**
 * Every payee seen, with the name and category it was given most recently
 * (a payee's display name can change; the key stays).
 */
export function payeesOf(txns: readonly Txn[]): Map<string, PayeeInfo> {
  const out = new Map<string, PayeeInfo & { at: number }>();
  for (const t of txns) {
    if (t.hidden || t.kind === "transfer") continue;
    const key = payeeKeyOf(t);
    if (!key) continue;
    const prior = out.get(key);
    if (!prior || t.at >= prior.at) out.set(key, { key, name: t.payeeDisplay ?? t.payeeKey ?? key, categoryId: t.categoryId ?? prior?.categoryId ?? null, at: t.at });
  }
  return out;
}
