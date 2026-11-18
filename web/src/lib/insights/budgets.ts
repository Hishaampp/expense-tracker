/**
 * The Budgets page: this month against the monthly and category budgets
 * (the app's budget snapshot), and the last months against today's budgets.
 * The phone keeps only the current budget amounts, so earlier months are
 * measured against them too.
 */
import type { Vault } from "@/lib/vault/vault";
import { inPeriod, safeToSpend, summarise, type Safe, type Txn } from "./money";
import { periodContaining, shifted, startDayFrom, type Period } from "./period";

export const BUDGET_HISTORY = 6;

export type BudgetMonth = { period: Period; monthly: number; byCategory: Map<string, number> };

export type Budgets = {
  monthly: number | null;
  byCategory: Map<string, number>;
  safe: Safe;
  /** Oldest first; the last is the month in progress. */
  months: BudgetMonth[];
};

export function budgetsOf(vault: Vault, txns: readonly Txn[], now: Date): Budgets {
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const current = periodContaining(today, startDayFrom(vault.tables.settings));
  const budgetRooms = new Set<string>();
  for (const [id, r] of vault.tables.rooms) if (r.counts_toward_monthly_budget === 1 || r.counts_toward_monthly_budget === true) budgetRooms.add(id);
  let monthly: number | null = null;
  const byCategory = new Map<string, number>();
  for (const b of vault.tables.budgets.values()) {
    const amount = Number(b.amount_paise);
    if (!Number.isSafeInteger(amount)) continue;
    if (typeof b.category_id === "string" && b.category_id) byCategory.set(b.category_id, amount);
    else monthly = amount;
  }
  const months: BudgetMonth[] = [];
  for (let i = BUDGET_HISTORY - 1; i >= 0; i--) {
    const period = shifted(current, -i);
    const s = summarise(inPeriod(txns, period), budgetRooms);
    months.push({ period, monthly: s.spentForBudget, byCategory: s.budgetByCategory });
  }
  const now_ = months.at(-1)!;
  return { monthly, byCategory, safe: safeToSpend(monthly, now_.monthly, current, today), months };
}
