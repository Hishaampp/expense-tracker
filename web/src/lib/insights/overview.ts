/**
 * Everything the Overview shows for one budgeting month, built from the
 * unlocked records with the app's own rules (money.ts, period.ts). Pure:
 * the page passes in the vault, "now" and which month.
 */
import type { Vault } from "@/lib/vault/vault";
import {
  carriedInto,
  dividedRounded,
  firstIncomeAt,
  inPeriod,
  safeToSpend,
  summarise,
  txnFromRow,
  type Safe,
  type Summary,
  type Txn,
} from "./money";
import { contains, daysElapsedOn, lengthInDays, periodContaining, shifted, startDayFrom, type Period } from "./period";

export const TREND_MONTHS = 12;
export const TOP_PAYEES = 6;

export type CategoryLine = {
  id: string | null;
  name: string;
  icon: string | null;
  spent: number;
  /** Share of the month's spending, 0–1. */
  share: number;
  /** The category's budget, when set; compared with [budgetSpent]. */
  budget: number | null;
  budgetSpent: number;
};

export type PayeeLine = { key: string; name: string; spent: number; payments: number; average: number };

export type TrendMonth = { start: Date; end: Date; spent: number; moneyIn: number; isShown: boolean };

export type HeatDay = { date: Date; spent: number; future: boolean };

export type Overview = {
  period: Period;
  previous: Period;
  offset: number;
  isCurrent: boolean;
  summary: Summary;
  previousSummary: Summary;
  /** Days counted for the daily average (so far, for the current month). */
  daysCounted: number;
  dailyAverage: number;
  previousDailyAverage: number;
  /** What carried in from earlier months, and what is left now. */
  carried: number;
  balance: number;
  showsBalance: boolean;
  payments: number;
  safe: Safe;
  categories: CategoryLine[];
  payees: PayeeLine[];
  trend: TrendMonth[];
  days: HeatDay[];
  /** The month before, day by day (to compare a month in progress fairly). */
  previousDays: HeatDay[];
  /** Captured payments still waiting for a category, all months. */
  needsReview: number;
  /** Whether anything at all was recorded, any month. */
  hasAny: boolean;
};

/** The vault's transactions, oldest first, rows Ample can't read left out. */
export function transactionsOf(vault: Vault): Txn[] {
  const out: Txn[] = [];
  for (const row of vault.tables.transactions.values()) {
    const t = txnFromRow(row);
    if (t) out.push(t);
  }
  return out.sort((a, b) => a.at - b.at);
}

function payeeLines(txns: readonly Txn[]): PayeeLine[] {
  const byKey = new Map<string, { name: string; nameAt: number; spent: number; payments: number }>();
  for (const t of txns) {
    if (t.hidden || (t.kind !== "expense" && t.kind !== "refund")) continue;
    const name = t.payeeDisplay ?? t.payeeKey;
    if (!name) continue;
    const key = t.payeeKey ?? name.toLowerCase();
    const line = byKey.get(key) ?? { name, nameAt: t.at, spent: 0, payments: 0 };
    if (t.at >= line.nameAt) {
      line.name = name;
      line.nameAt = t.at;
    }
    if (t.kind === "expense") {
      line.spent += t.paise;
      line.payments++;
    } else line.spent -= t.paise;
    byKey.set(key, line);
  }
  return [...byKey]
    .filter(([, l]) => l.spent > 0 && l.payments > 0)
    .map(([key, l]) => ({ key, name: l.name, spent: l.spent, payments: l.payments, average: dividedRounded(l.spent, l.payments) }))
    .sort((a, b) => b.spent - a.spent || a.name.localeCompare(b.name))
    .slice(0, TOP_PAYEES);
}

function heatDays(txns: readonly Txn[], p: Period, today: Date): HeatDay[] {
  const days: HeatDay[] = [];
  const n = lengthInDays(p);
  const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
  for (let i = 0; i < n; i++) {
    const date = new Date(p.start.getFullYear(), p.start.getMonth(), p.start.getDate() + i);
    days.push({ date, spent: 0, future: date.getTime() > todayStart });
  }
  for (const t of txns) {
    if (t.hidden || (t.kind !== "expense" && t.kind !== "refund")) continue;
    const d = new Date(t.at);
    const local = new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
    const index = days.findIndex((x) => x.date.getTime() === local);
    if (index >= 0) days[index].spent += t.kind === "expense" ? t.paise : -t.paise;
  }
  return days;
}

/** The Overview for the month [offset] months from the current one (0 or less). */
export function overview(vault: Vault, now: Date, offset: number, txns: readonly Txn[] = transactionsOf(vault)): Overview {
  const startDay = startDayFrom(vault.tables.settings);
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const current = periodContaining(today, startDay);
  const period = shifted(current, offset);
  const previous = shifted(period, -1);

  const budgetRooms = new Set<string>();
  for (const [id, r] of vault.tables.rooms) {
    if (r.counts_toward_monthly_budget === 1 || r.counts_toward_monthly_budget === true) budgetRooms.add(String(r.id ?? id));
  }
  let monthlyBudget: number | null = null;
  const categoryBudgets = new Map<string, number>();
  for (const b of vault.tables.budgets.values()) {
    const amount = Number(b.amount_paise);
    if (!Number.isSafeInteger(amount)) continue;
    if (typeof b.category_id === "string" && b.category_id) categoryBudgets.set(b.category_id, amount);
    else monthlyBudget = amount;
  }

  const shown = inPeriod(txns, period);
  const summary = summarise(shown, budgetRooms);
  const previousSummary = summarise(inPeriod(txns, previous), budgetRooms);
  const daysCounted = daysElapsedOn(period, today);
  const first = firstIncomeAt(txns);
  const carried = carriedInto(txns, period, first === null ? null : periodContaining(new Date(first), startDay).start.getTime());

  const categories: CategoryLine[] = summary.byCategory.map(({ categoryId, spent }) => {
    const row = categoryId ? vault.tables.categories.get(categoryId) : undefined;
    return {
      id: categoryId,
      name: typeof row?.name === "string" ? row.name : "Uncategorised",
      icon: typeof row?.icon === "string" ? row.icon : null,
      spent,
      share: summary.spent > 0 ? spent / summary.spent : 0,
      budget: categoryId ? (categoryBudgets.get(categoryId) ?? null) : null,
      budgetSpent: summary.budgetByCategory.get(categoryId ?? "") ?? 0,
    };
  });

  const trend: TrendMonth[] = [];
  for (let i = TREND_MONTHS - 1; i >= 0; i--) {
    const p = shifted(period, -i);
    const s = summarise(inPeriod(txns, p), budgetRooms);
    trend.push({ start: p.start, end: p.end, spent: s.spent, moneyIn: s.moneyIn, isShown: i === 0 });
  }

  return {
    period,
    previous,
    offset,
    isCurrent: offset === 0,
    summary,
    previousSummary,
    daysCounted,
    dailyAverage: dividedRounded(summary.spent, daysCounted),
    previousDailyAverage: dividedRounded(previousSummary.spent, lengthInDays(previous)),
    carried,
    balance: carried + summary.moneyIn - summary.spent,
    showsBalance: summary.moneyIn > 0 || carried !== 0,
    payments: shown.filter((t) => !t.hidden && t.kind === "expense").length,
    safe: offset === 0 ? safeToSpend(monthlyBudget, summary.spentForBudget, period, today) : { kind: "none" },
    categories,
    payees: payeeLines(shown),
    trend,
    days: heatDays(shown, period, today),
    previousDays: heatDays(inPeriod(txns, previous), previous, today),
    needsReview: txns.filter((t) => t.needsReview && !t.hidden).length,
    hasAny: txns.length > 0,
  };
}

/** Whether [ms] is in the month shown. */
export const isInShown = (o: Overview, ms: number) => contains(o.period, ms);
