import type { RecordPayload, SealedRecord, SyncCrypto } from "@/lib/crypto/sync-crypto";

/** The tables the phone syncs (lib/data/sync/sync_engine.dart). */
export const SYNCED_TABLES = [
  "accounts",
  "categories",
  "rooms",
  "transactions",
  "budgets",
  "payee_rules",
  "settings",
] as const;

export type SyncedTable = (typeof SYNCED_TABLES)[number];

export type Row = Record<string, unknown>;

/** Everything unlocked, held only in this tab's memory. */
export type Vault = {
  tables: Record<SyncedTable, Map<string, Row>>;
  /** Records this key could not open (another key, or damaged). */
  unreadable: number;
  /** Records opened, including deletions. */
  opened: number;
  /** The newest change in the account, in ms since the epoch. */
  lastChangedAt: number | null;
};

function emptyTables(): Vault["tables"] {
  return Object.fromEntries(
    SYNCED_TABLES.map((t) => [t, new Map<string, Row>()]),
  ) as Vault["tables"];
}

/**
 * Opens [records] with [crypto] and keeps, per row, its newest change; a
 * deletion removes the row. Unknown tables are ignored (a newer app).
 * Reports progress after each batch so the screen can show it.
 */
export async function openVault(
  records: SealedRecord[],
  crypto: Pick<SyncCrypto, "open">,
  onProgress?: (done: number, total: number) => void,
  batch = 200,
): Promise<Vault> {
  const newest = new Map<string, RecordPayload>();
  let unreadable = 0;
  let opened = 0;
  for (let i = 0; i < records.length; i += batch) {
    const slice = records.slice(i, i + batch);
    const payloads = await Promise.all(slice.map((r) => crypto.open(r)));
    for (const p of payloads) {
      if (!p) {
        unreadable++;
        continue;
      }
      opened++;
      const id = `${p.table}\u0000${p.key}`;
      const prior = newest.get(id);
      if (!prior || prior.changedAt <= p.changedAt) newest.set(id, p);
    }
    onProgress?.(Math.min(i + batch, records.length), records.length);
  }
  const tables = emptyTables();
  let lastChangedAt: number | null = null;
  for (const p of newest.values()) {
    lastChangedAt = Math.max(lastChangedAt ?? 0, p.changedAt);
    if (!(SYNCED_TABLES as readonly string[]).includes(p.table)) continue;
    if (p.row) tables[p.table as SyncedTable].set(p.key, p.row);
  }
  return { tables, unreadable, opened, lastChangedAt };
}
