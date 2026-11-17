import type { Vault } from "@/lib/vault/vault";

/** What came across from the phone: counts only, no money maths yet. */
export type Inventory = {
  payments: number;
  moneyIn: number;
  refunds: number;
  transfers: number;
  needsReview: number;
  accounts: number;
  categories: number;
  rooms: number;
  budgets: number;
  firstAt: number | null;
  lastAt: number | null;
};

export function inventory(vault: Vault): Inventory {
  const inv: Inventory = {
    payments: 0,
    moneyIn: 0,
    refunds: 0,
    transfers: 0,
    needsReview: 0,
    accounts: 0,
    categories: 0,
    rooms: 0,
    budgets: vault.tables.budgets.size,
    firstAt: null,
    lastAt: null,
  };
  for (const t of vault.tables.transactions.values()) {
    if (t.kind === "expense") inv.payments++;
    else if (t.kind === "income") inv.moneyIn++;
    else if (t.kind === "refund") inv.refunds++;
    else if (t.kind === "transfer") inv.transfers++;
    if (t.review_status !== "confirmed" && !t.is_hidden) inv.needsReview++;
    const at = Number(t.occurred_at);
    if (Number.isFinite(at)) {
      inv.firstAt = inv.firstAt === null ? at : Math.min(inv.firstAt, at);
      inv.lastAt = inv.lastAt === null ? at : Math.max(inv.lastAt, at);
    }
  }
  for (const a of vault.tables.accounts.values()) if (!a.is_archived) inv.accounts++;
  for (const c of vault.tables.categories.values()) if (!c.is_archived) inv.categories++;
  inv.rooms = vault.tables.rooms.size;
  return inv;
}
