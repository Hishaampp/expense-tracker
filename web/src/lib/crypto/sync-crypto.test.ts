import { describe, expect, it } from "vitest";
import vectors from "./fixtures/sync-vectors.json";
import { SyncCrypto } from "./sync-crypto";
import {
  formatRecoveryCode,
  keyFromRecoveryCode,
} from "./sync-key";

// Sealed by the app's own SyncCrypto: test/data/sync/web_vectors_test.dart.
describe("sync key", () => {
  it("reads the app's recovery code back to the key bytes", () => {
    expect(Array.from(keyFromRecoveryCode(vectors.recoveryCode)!)).toEqual(
      vectors.keyBytes,
    );
  });

  it("forgives spaces, case and look-alike letters", () => {
    const sloppy = vectors.recoveryCode
      .replace(/-/g, " ")
      .toLowerCase()
      .replace(/0/g, "o")
      .replace(/1/g, "l");
    expect(keyFromRecoveryCode(sloppy)).not.toBeNull();
  });

  it("catches a mistyped character", () => {
    const code = vectors.recoveryCode;
    const i = code.indexOf("R");
    const typo = code.slice(0, i) + "S" + code.slice(i + 1);
    expect(keyFromRecoveryCode(typo)).toBeNull();
    expect(keyFromRecoveryCode(code.slice(0, -2))).toBeNull();
  });

  it("formats as the app shows it", () => {
    expect(formatRecoveryCode(vectors.recoveryCode.replace(/-/g, ""))).toBe(
      vectors.recoveryCode,
    );
  });
});

describe("sync crypto", () => {
  it("opens every record the app sealed, to the same content", async () => {
    const crypto = await SyncCrypto.create(Uint8Array.from(vectors.keyBytes));
    for (const record of vectors.records) {
      const opened = await crypto.open(record);
      expect(opened).toEqual({
        table: record.opened.t,
        key: record.opened.k,
        changedAt: record.opened.at,
        row: record.opened.row,
      });
    }
  });

  it("makes the same record ids", async () => {
    const crypto = await SyncCrypto.create(Uint8Array.from(vectors.keyBytes));
    const first = vectors.records[0];
    expect(await crypto.recordId(first.opened.t, first.opened.k)).toBe(
      first.id,
    );
  });

  it("refuses a record sealed with another key", async () => {
    const crypto = await SyncCrypto.create(Uint8Array.from(vectors.keyBytes));
    expect(await crypto.open(vectors.foreignRecord)).toBeNull();
  });

  it("refuses a tampered record or a swapped id", async () => {
    const crypto = await SyncCrypto.create(Uint8Array.from(vectors.keyBytes));
    const [a, b] = vectors.records;
    const blob = a.blob.slice(0, 40) + (a.blob[40] === "A" ? "B" : "A") +
      a.blob.slice(41);
    expect(await crypto.open({ ...a, blob })).toBeNull();
    expect(await crypto.open({ ...a, id: b.id })).toBeNull();
    expect(await crypto.open({ ...a, blob: "not base64!" })).toBeNull();
  });
});
