/**
 * The sync key, ported from the app's `SyncKey` (lib/data/sync/sync_crypto.dart).
 * The recovery code is the 32 key bytes plus a check byte, in Crockford-style
 * base32, in groups of four. Shared test cases keep the two in step.
 */

export const KEY_LENGTH = 32;

const ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

/** A one-byte checksum: the low byte of a weighted running sum. */
function check(key: Uint8Array): number {
  let sum = 0;
  key.forEach((b, i) => {
    sum = (sum + b * (i + 1)) & 0xff;
  });
  return sum;
}

function base32Decode(text: string): Uint8Array | null {
  const out: number[] = [];
  let buffer = 0;
  let bits = 0;
  for (const char of text) {
    const value = ALPHABET.indexOf(char);
    if (value < 0) return null;
    buffer = ((buffer << 5) | value) & 0xffff;
    bits += 5;
    if (bits >= 8) {
      out.push((buffer >> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }
  return Uint8Array.from(out);
}

/** The code as typed, cleaned the way the app reads it. */
export function normalizeRecoveryCode(code: string): string {
  return code
    .toUpperCase()
    .replace(/[\s-]/g, "")
    .replace(/O/g, "0")
    .replace(/[IL]/g, "1");
}

/** Characters in a complete recovery code, without dashes. */
export const RECOVERY_CODE_LENGTH = 53;

/** [code] formatted in groups of four, as the app shows it. */
export function formatRecoveryCode(code: string): string {
  const clean = normalizeRecoveryCode(code).slice(0, RECOVERY_CODE_LENGTH);
  return clean.match(/.{1,4}/g)?.join("-") ?? "";
}

/** The key bytes for a recovery [code], or null when it is mistyped. */
export function keyFromRecoveryCode(code: string): Uint8Array | null {
  const bytes = base32Decode(normalizeRecoveryCode(code));
  if (!bytes || bytes.length !== KEY_LENGTH + 1) return null;
  const key = bytes.slice(0, KEY_LENGTH);
  return bytes[KEY_LENGTH] === check(key) ? key : null;
}
