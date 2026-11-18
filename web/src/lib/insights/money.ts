/**
 * Totals ported from the app's lib/core/month_summary.dart,
 * lib/core/safe_to_spend.dart and Money.dividedRounded. Money is integer
 * paise throughout; nothing is ever a float until it is shown.
 */
import type { Row } from "@/lib/vault/vault";
import { contains, daysLeftIncluding, type Period } from "./period";

export type Kind = "expense" | "refund" | "income" | "transfer";

export type Txn = {
  id: string;
  kind: Kind;
  paise: number;
  at: number;
  categoryId: string | null;
  roomId: string | null;
  payeeKey: string | null;
  payeeDisplay: string | null;
  hidden: boolean;
  needsReview: boolean;
  accountId: string | null;
  toAccountId: string | null;
  note: string | null;
  /** "manual" (typed in) or "auto" (captured). */
  origin: string;
  instrument: string | null;
  refNo: string | null;
  linkedId: string | null;
  createdAt: number;
};

const text = (v: unknown) => (typeof v === "string" && v !== "" ? v : null);

/** A synced transactions row as a [Txn]; null when it is not one Ample understands. */
export function txnFromRow(row: Row): Txn | null {
  const kind = row.kind;
  if (kind !== "expense" && kind !== "refund" && kind !== "income" && kind !== "transfer") return null;
  const paise = Number(row.amount_paise);
  const at = Number(row.occurred_at);
  if (!Number.isSafeInteger(paise) || !Number.isFinite(at)) return null;
  return {
    id: String(row.id),
    kind,
    paise,
    at,
    categoryId: text(row.category_id),
    roomId: text(row.room_id),
    payeeKey: text(row.payee_key),
    payeeDisplay: text(row.payee_display),
    hidden: row.is_hidden === 1 || row.is_hidden === true,
    needsReview: row.review_status === "needsReview",
    accountId: text(row.account_id),
    toAccountId: text(row.to_account_id),
    note: text(row.note),
    origin: text(row.origin) ?? "manual",
    instrument: text(row.instrument),
    refNo: text(row.ref_no),
    linkedId: text(row.linked_transaction_id),
    createdAt: Number(row.created_at) || at,
  };
}

export type Summary = {
  /** Expenses minus refunds, Rooms included. */
  spent: number;
  spentInRooms: number;
  /** What the monthly budget counts: Rooms that stay out are left out. */
  spentForBudget: number;
  moneyIn: number;
  /** Spending per category, largest first; positive totals only. */
  byCategory: { categoryId: string | null; spent: number }[];
  /** Budget-counted spending per category ("" is uncategorised). */
  budgetByCategory: Map<string, number>;
};

/** MonthSummary.of: hidden and transfers ignored, a refund reduces spending. */
export function summarise(txns: Iterable<Txn>, budgetRoomIds: ReadonlySet<string> = new Set()): Summary {
  let spent = 0;
  let inRooms = 0;
  let outsideBudget = 0;
  let moneyIn = 0;
  const perCategory = new Map<string | null, number>();
  const budgetCategory = new Map<string, number>();
  for (const t of txns) {
    if (t.hidden) continue;
    if (t.kind === "income") {
      moneyIn += t.paise;
      continue;
    }
    if (t.kind === "transfer") continue;
    const signed = t.kind === "expense" ? t.paise : -t.paise;
    spent += signed;
    if (t.roomId !== null) {
      inRooms += signed;
      if (!budgetRoomIds.has(t.roomId)) outsideBudget += signed;
    }
    perCategory.set(t.categoryId, (perCategory.get(t.categoryId) ?? 0) + signed);
    if (t.roomId === null || budgetRoomIds.has(t.roomId)) {
      const key = t.categoryId ?? "";
      budgetCategory.set(key, (budgetCategory.get(key) ?? 0) + signed);
    }
  }
  const byCategory = [...perCategory]
    .filter(([, v]) => v > 0)
    .map(([categoryId, v]) => ({ categoryId, spent: v }))
    .sort((a, b) => b.spent - a.spent);
  return { spent, spentInRooms: inRooms, spentForBudget: spent - outsideBudget, moneyIn, byCategory, budgetByCategory: budgetCategory };
}

/** Money.dividedRounded: half away from zero; 0 parts gives 0. */
export function dividedRounded(paise: number, parts: number): number {
  if (parts <= 0) return 0;
  const sign = paise < 0 ? -1 : 1;
  return sign * Math.floor((Math.abs(paise) * 2 + parts) / (parts * 2));
}

export type Safe =
  | { kind: "none" }
  | { kind: "onTrack"; budget: number; spent: number; left: number; daysLeft: number; perDay: number }
  | { kind: "over"; budget: number; spent: number; over: number };

/** SafeToSpend.of: what is left ÷ days left (today included), rounded down. */
export function safeToSpend(budget: number | null, spent: number, period: Period, today: Date): Safe {
  if (budget === null || budget <= 0) return { kind: "none" };
  const left = budget - spent;
  if (left < 0) return { kind: "over", budget, spent, over: spent - budget };
  const daysLeft = Math.max(1, daysLeftIncluding(period, today));
  return { kind: "onTrack", budget, spent, left, daysLeft, perDay: Math.floor(left / daysLeft) };
}

/** Transactions inside [p]. */
export const inPeriod = (txns: readonly Txn[], p: Period) => txns.filter((t) => contains(p, t.at));

/**
 * What carried into [p] (Home's balance): money in minus money spent from
 * the start of the period holding the first income up to [p]'s start.
 */
export function carriedInto(txns: readonly Txn[], p: Period, firstIncomePeriodStart: number | null): number {
  const end = p.start.getTime();
  if (firstIncomePeriodStart === null || firstIncomePeriodStart >= end) return 0;
  let net = 0;
  for (const t of txns) {
    if (t.hidden || t.at < firstIncomePeriodStart || t.at >= end) continue;
    if (t.kind === "income" || t.kind === "refund") net += t.paise;
    else if (t.kind === "expense") net -= t.paise;
  }
  return net;
}

/** When the first (visible) income was received, or null. */
export function firstIncomeAt(txns: readonly Txn[]): number | null {
  let first: number | null = null;
  for (const t of txns) if (!t.hidden && t.kind === "income") first = first === null ? t.at : Math.min(first, t.at);
  return first;
}
