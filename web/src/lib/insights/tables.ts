/**
 * The website's lists: transactions joined to their names, the app's
 * Activity search and filters (lib/core/transaction_filter.dart), Room
 * totals (lib/core/room_summary.dart), and month-by-month histories.
 */
import type { Vault } from "@/lib/vault/vault";
import { inPeriod, summarise, type Kind, type Txn } from "./money";
import { periodContaining, shifted, startDayFrom, type Period } from "./period";

export type Named = { id: string; name: string };

/** A transaction with the names it points to. */
export type Item = {
  t: Txn;
  category: (Named & { icon: string | null }) | null;
  account: Named | null;
  toAccount: Named | null;
  room: (Named & { emoji: string | null }) | null;
};

export type Lookup = {
  categories: Map<string, Named & { icon: string | null; kind: string; archived: boolean }>;
  accounts: Map<string, Named & { archived: boolean }>;
  rooms: Map<string, RoomInfo>;
};

export type RoomInfo = Named & {
  emoji: string | null;
  type: string;
  /** Local days since 1970-01-01, as the app stores them. */
  startDay: number | null;
  endDay: number | null;
  budget: number | null;
  countsTowardBudget: boolean;
  archived: boolean;
};

const str = (v: unknown) => (typeof v === "string" && v !== "" ? v : null);
const int = (v: unknown) => (v === null || v === undefined || v === "" ? null : Number.isSafeInteger(Number(v)) ? Number(v) : null);
const yes = (v: unknown) => v === 1 || v === true;

export function lookupOf(vault: Vault): Lookup {
  const categories: Lookup["categories"] = new Map();
  for (const [id, r] of vault.tables.categories)
    categories.set(id, { id, name: str(r.name) ?? "Category", icon: str(r.icon), kind: str(r.kind) ?? "expense", archived: yes(r.is_archived) });
  const accounts: Lookup["accounts"] = new Map();
  for (const [id, r] of vault.tables.accounts) accounts.set(id, { id, name: str(r.name) ?? "Account", archived: yes(r.is_archived) });
  const rooms: Lookup["rooms"] = new Map();
  for (const [id, r] of vault.tables.rooms)
    rooms.set(id, {
      id,
      name: str(r.name) ?? "Room",
      emoji: str(r.emoji),
      type: str(r.type) ?? "custom",
      startDay: int(r.start_day),
      endDay: int(r.end_day),
      budget: int(r.budget_paise),
      countsTowardBudget: yes(r.counts_toward_monthly_budget),
      archived: r.status === "archived",
    });
  return { categories, accounts, rooms };
}

/** [txns] joined to their names. */
export function itemsOf(txns: readonly Txn[], l: Lookup): Item[] {
  return txns.map((t) => {
    const c = t.categoryId ? l.categories.get(t.categoryId) : undefined;
    const a = t.accountId ? l.accounts.get(t.accountId) : undefined;
    const to = t.toAccountId ? l.accounts.get(t.toAccountId) : undefined;
    const r = t.roomId ? l.rooms.get(t.roomId) : undefined;
    return {
      t,
      category: c ? { id: c.id, name: c.name, icon: c.icon } : null,
      account: a ? { id: a.id, name: a.name } : null,
      toAccount: to ? { id: to.id, name: to.name } : null,
      room: r ? { id: r.id, name: r.name, emoji: r.emoji } : null,
    };
  });
}

export type Filter = {
  query: string;
  categoryId: string | null;
  roomId: string | null;
  accountId: string | null;
  kind: Kind | null;
  origin: string | null;
  /** Web only: captured payments still waiting for a category. */
  needsReview: boolean;
  /** Web only: a date range, local midnight bounds (end exclusive). */
  from: number | null;
  to: number | null;
};

export const NO_FILTER: Filter = { query: "", categoryId: null, roomId: null, accountId: null, kind: null, origin: null, needsReview: false, from: null, to: null };

/** How many filters (not the search) are set. */
export const filterCount = (f: Filter) =>
  [f.categoryId, f.roomId, f.accountId, f.kind, f.origin].filter((v) => v !== null).length + (f.needsReview ? 1 : 0) + (f.from !== null || f.to !== null ? 1 : 0);

/** The amount as Activity searches it: "240" or "240.05". */
function amountText(paise: number): string {
  const rupees = Math.trunc(paise / 100);
  const part = Math.abs(paise) % 100;
  return part === 0 ? `${rupees}` : `${rupees}.${String(part).padStart(2, "0")}`;
}

/**
 * TransactionFilter.matches: a typed amount matches by its leading digits
 * ("24" finds ₹240); words must all appear in the payee, UPI id, note,
 * category or account.
 */
export function matches(item: Item, f: Filter): boolean {
  const t = item.t;
  if (f.categoryId !== null && t.categoryId !== f.categoryId) return false;
  if (f.roomId !== null && t.roomId !== f.roomId) return false;
  if (f.accountId !== null && t.accountId !== f.accountId) return false;
  if (f.kind !== null && t.kind !== f.kind) return false;
  if (f.origin !== null && t.origin !== f.origin) return false;
  if (f.needsReview && !t.needsReview) return false;
  if (f.from !== null && t.at < f.from) return false;
  if (f.to !== null && t.at >= f.to) return false;
  const text = f.query.trim().toLowerCase();
  if (!text) return true;
  const digits = text.replace(/[₹,\s]/g, "");
  if (/^\d+(\.\d+)?$/.test(digits)) return amountText(t.paise).startsWith(digits);
  const haystack = [t.payeeDisplay, t.payeeKey, t.note, item.category?.name, item.account?.name]
    .filter((v): v is string => typeof v === "string")
    .join(" ")
    .toLowerCase();
  return text.split(/\s+/).every((w) => haystack.includes(w));
}

/** Local days since 1970-01-01 for [ms], the app's LocalDay. */
export const localDay = (ms: number) => {
  const d = new Date(ms);
  return Math.round(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / 86_400_000);
};

/** The local date of a LocalDay value. */
export const dateOfDay = (day: number) => {
  const u = new Date(day * 86_400_000);
  return new Date(u.getUTCFullYear(), u.getUTCMonth(), u.getUTCDate());
};

export type RoomSummary = {
  spent: number;
  byCategory: { categoryId: string | null; spent: number }[];
  /** Spending per local day (positive days only), newest first. */
  byDay: { day: number; spent: number }[];
  days: number | null;
  perDay: number | null;
  remaining: number | null;
  progress: number | null;
};

/** RoomSummary.of over the Room's own transactions. */
export function roomSummary(room: RoomInfo, txns: readonly Txn[], today: number): RoomSummary {
  const s = summarise(txns);
  const perDay = new Map<number, number>();
  for (const t of txns) {
    if (t.hidden) continue;
    const sign = t.kind === "expense" ? 1 : t.kind === "refund" ? -1 : 0;
    if (sign === 0) continue;
    const d = localDay(t.at);
    perDay.set(d, (perDay.get(d) ?? 0) + sign * t.paise);
  }
  const byDay = [...perDay].filter(([, v]) => v > 0).map(([day, spent]) => ({ day, spent })).sort((a, b) => b.day - a.day);
  let days: number | null = null;
  if (room.startDay !== null && today >= room.startDay) {
    const last = room.endDay === null || today < room.endDay ? today : room.endDay;
    days = last - room.startDay + 1;
  }
  return {
    spent: s.spent,
    byCategory: s.byCategory,
    byDay,
    days,
    perDay: days ? Math.trunc(s.spent / days) : null,
    remaining: room.budget === null ? null : room.budget - s.spent,
    progress: room.budget === null || room.budget === 0 ? null : s.spent / room.budget,
  };
}

export type MonthPoint = { period: Period; spent: number; moneyIn: number; count: number };

/**
 * [months] budgeting months up to the current one, each summed over the
 * transactions [pick] keeps (a category, a payee).
 */
export function history(vault: Vault, txns: readonly Txn[], now: Date, months: number, pick: (t: Txn) => boolean): MonthPoint[] {
  const current = periodContaining(new Date(now.getFullYear(), now.getMonth(), now.getDate()), startDayFrom(vault.tables.settings));
  const out: MonthPoint[] = [];
  const mine = txns.filter(pick);
  for (let i = months - 1; i >= 0; i--) {
    const period = shifted(current, -i);
    const these = inPeriod(mine, period);
    const s = summarise(these);
    out.push({ period, spent: s.spent, moneyIn: s.moneyIn, count: these.filter((t) => !t.hidden && t.kind === "expense").length });
  }
  return out;
}

/** The key a payee is grouped by (Overview's top payees use the same). */
export const payeeKeyOf = (t: Txn) => t.payeeKey ?? t.payeeDisplay?.toLowerCase() ?? null;
