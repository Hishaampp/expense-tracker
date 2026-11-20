import { describe, expect, it } from "vitest";
import vectors from "@/lib/crypto/fixtures/sync-vectors.json";
import { SyncCrypto } from "@/lib/crypto/sync-crypto";
import { openVault } from "./vault";

describe("openVault", () => {
  it("opens the app's records into tables, dropping deletions", async () => {
    const crypto = await SyncCrypto.create(Uint8Array.from(vectors.keyBytes));
    const seen: number[] = [];
    const vault = await openVault(
      [...vectors.records, vectors.foreignRecord],
      crypto,
      (done) => seen.push(done),
      2,
    );
    expect(vault.tables.transactions.get("t-1")?.amount_paise).toBe(6000);
    expect(vault.tables.transactions.has("t-2")).toBe(false);
    expect(vault.tables.settings.get("month_start_day")?.value).toBe("5");
    expect(vault.unreadable).toBe(1);
    expect(vault.opened).toBe(3);
    expect(seen).toEqual([2, 4]);
    expect(vault.lastChangedAt).toBe(1763365400000);
  });

  it("keeps the newest change of a row", async () => {
    const old = { table: "settings", key: "k", changedAt: 1, row: { value: "old" } };
    const fresh = { table: "settings", key: "k", changedAt: 2, row: { value: "new" } };
    const fake = {
      open: async (r: { id: string }) => (r.id === "a" ? fresh : old),
    };
    const vault = await openVault(
      [
        { id: "a", changed_at: 2, blob: "" },
        { id: "b", changed_at: 1, blob: "" },
      ],
      fake,
    );
    expect(vault.tables.settings.get("k")?.value).toBe("new");
  });
});
