import type { SupabaseClient } from "@supabase/supabase-js";
import type { SealedRecord } from "@/lib/crypto/sync-crypto";

const PAGE = 1000;

/**
 * Every sealed record of the signed-in user, oldest change first, as the
 * phone pulls them (by `seq`). Row-level security limits it to this user.
 */
export async function fetchSealedRecords(
  db: SupabaseClient,
  onPage?: (loaded: number) => void,
): Promise<SealedRecord[]> {
  const out: SealedRecord[] = [];
  let cursor = 0;
  for (;;) {
    const { data, error } = await db
      .from("sync_records")
      .select("seq, id, changed_at, blob")
      .gt("seq", cursor)
      .order("seq")
      .limit(PAGE);
    if (error) throw new CloudError(error.message);
    for (const row of data) {
      out.push({ id: row.id, changed_at: Number(row.changed_at), blob: row.blob });
    }
    onPage?.(out.length);
    if (data.length < PAGE) return out;
    cursor = Number(data[data.length - 1].seq);
  }
}

/** The cloud could not be reached or refused the request. */
export class CloudError extends Error {}
