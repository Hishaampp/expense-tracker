/**
 * Opens sync records, ported from the app's `SyncCrypto`
 * (lib/data/sync/sync_crypto.dart): AES-256-GCM for the content and an
 * HMAC-SHA-256 record id, both keyed by HKDF-SHA-256 from the sync key.
 * Everything runs in this browser tab with WebCrypto; the derived keys are
 * not extractable.
 */

/** A record as the server stores it. */
export type SealedRecord = { id: string; changed_at: number; blob: string };

/** What an opened record holds; `row` is null when it was deleted. */
export type RecordPayload = {
  table: string;
  key: string;
  changedAt: number;
  row: Record<string, unknown> | null;
};

const encoder = new TextEncoder();
const decoder = new TextDecoder();

function toHex(bytes: ArrayBuffer): string {
  return Array.from(new Uint8Array(bytes), (b) =>
    b.toString(16).padStart(2, "0"),
  ).join("");
}

function fromBase64(text: string): Uint8Array {
  const raw = atob(text);
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}

async function derive(
  master: CryptoKey,
  purpose: string,
  algorithm: AesKeyGenParams | HmacKeyGenParams,
  usages: KeyUsage[],
): Promise<CryptoKey> {
  return crypto.subtle.deriveKey(
    {
      name: "HKDF",
      hash: "SHA-256",
      // The app's HKDF uses no salt: an all-zero salt of hash length.
      salt: new Uint8Array(32),
      info: encoder.encode(purpose),
    },
    master,
    algorithm,
    false,
    usages,
  );
}

/** The opener for one sync key. */
export class SyncCrypto {
  private constructor(
    private readonly contentKey: CryptoKey,
    private readonly idKey: CryptoKey,
  ) {}

  /** Derives the record keys from the raw sync [key] bytes. */
  static async create(key: Uint8Array): Promise<SyncCrypto> {
    const master = await crypto.subtle.importKey(
      "raw",
      key as BufferSource,
      "HKDF",
      false,
      ["deriveKey"],
    );
    const [content, id] = await Promise.all([
      derive(master, "records-v1", { name: "AES-GCM", length: 256 }, [
        "decrypt",
      ]),
      derive(
        master,
        "ids-v1",
        { name: "HMAC", hash: "SHA-256", length: 256 },
        ["sign"],
      ),
    ]);
    return new SyncCrypto(content, id);
  }

  /** The opaque id of the record for [recordKey] in [table]. */
  async recordId(table: string, recordKey: string): Promise<string> {
    const mac = await crypto.subtle.sign(
      "HMAC",
      this.idKey,
      encoder.encode(`${table}\u0000${recordKey}`),
    );
    return toHex(mac);
  }

  /**
   * Opens [record], or returns null when it was not sealed with this key,
   * was changed on the way, or its id does not match its content.
   */
  async open(record: SealedRecord): Promise<RecordPayload | null> {
    let bytes: Uint8Array;
    try {
      bytes = fromBase64(record.blob);
    } catch {
      return null;
    }
    if (bytes.length < 12 + 16) return null;
    let plain: ArrayBuffer;
    try {
      // WebCrypto takes the tag appended to the ciphertext, as stored.
      plain = await crypto.subtle.decrypt(
        { name: "AES-GCM", iv: bytes.subarray(0, 12) as BufferSource },
        this.contentKey,
        bytes.subarray(12) as BufferSource,
      );
    } catch {
      return null;
    }
    let data: unknown;
    try {
      data = JSON.parse(decoder.decode(plain));
    } catch {
      return null;
    }
    if (!isPayloadJson(data)) return null;
    if ((await this.recordId(data.t, data.k)) !== record.id) return null;
    return { table: data.t, key: data.k, changedAt: data.at, row: data.row };
  }
}

type PayloadJson = {
  t: string;
  k: string;
  at: number;
  row: Record<string, unknown> | null;
};

function isPayloadJson(value: unknown): value is PayloadJson {
  if (typeof value !== "object" || value === null) return false;
  const v = value as Record<string, unknown>;
  return (
    typeof v.t === "string" &&
    typeof v.k === "string" &&
    typeof v.at === "number" &&
    (v.row === null || (typeof v.row === "object" && !Array.isArray(v.row)))
  );
}
