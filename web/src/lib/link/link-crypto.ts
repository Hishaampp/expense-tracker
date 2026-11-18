/**
 * The website's half of "Link a computer". Ported against the app's
 * lib/data/sync/computer_link.dart (version 2): X25519 between this tab's
 * one-time key and the phone's one-time key, HKDF-SHA-256
 * ("ample-link-v2") to an AES-256-GCM key, the request id as associated
 * data. What it opens is the phone's pass: the sync key and a one-time
 * sign-in for its account. Only a signed-in phone can let a computer in.
 */

const encoder = new TextEncoder();
const decoder = new TextDecoder();

function base64UrlNoPad(bytes: Uint8Array): string {
  let text = "";
  bytes.forEach((b) => (text += String.fromCharCode(b)));
  return btoa(text).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function fromBase64(text: string): Uint8Array {
  const raw = atob(text);
  return Uint8Array.from(raw, (c) => c.charCodeAt(0));
}

function randomHex(bytes: number): string {
  return Array.from(crypto.getRandomValues(new Uint8Array(bytes)), (b) =>
    b.toString(16).padStart(2, "0"),
  ).join("");
}

/** What the phone hands this tab: the sync key and a one-time sign-in. */
export type PhonePass = { key: Uint8Array; email: string; tokenHash: string };

/** One request: the QR text to show, and how to open the phone's answer. */
export type LinkRequest = {
  id: string;
  qr: string;
  open: (phoneKey: string, sealed: string) => Promise<PhonePass | null>;
};

function passFrom(plain: ArrayBuffer): PhonePass | null {
  let data: unknown;
  try {
    data = JSON.parse(decoder.decode(plain));
  } catch {
    return null;
  }
  if (typeof data !== "object" || data === null) return null;
  const { v, key, email, token } = data as Record<string, unknown>;
  if (v !== 2 || typeof key !== "string" || typeof email !== "string" || typeof token !== "string" || !token) return null;
  const bytes = fromBase64(key);
  return bytes.length === 32 ? { key: bytes, email, tokenHash: token } : null;
}

/** Builds a request around an existing key pair (tests pass a fixed one). */
export async function linkRequestFrom(
  keyPair: CryptoKeyPair,
  id: string,
): Promise<LinkRequest> {
  const publicRaw = new Uint8Array(await crypto.subtle.exportKey("raw", keyPair.publicKey));
  return {
    id,
    qr: `AMPLE2:${id}:${base64UrlNoPad(publicRaw)}`,
    open: async (phoneKey, sealed) => {
      try {
        const phonePublic = await crypto.subtle.importKey(
          "raw",
          fromBase64(phoneKey) as BufferSource,
          { name: "X25519" },
          false,
          [],
        );
        const shared = await crypto.subtle.deriveBits(
          { name: "X25519", public: phonePublic },
          keyPair.privateKey,
          256,
        );
        const hkdf = await crypto.subtle.importKey("raw", shared, "HKDF", false, ["deriveKey"]);
        const boxKey = await crypto.subtle.deriveKey(
          { name: "HKDF", hash: "SHA-256", salt: new Uint8Array(32), info: encoder.encode("ample-link-v2") },
          hkdf,
          { name: "AES-GCM", length: 256 },
          false,
          ["decrypt"],
        );
        const bytes = fromBase64(sealed);
        if (bytes.length < 12 + 16) return null;
        const plain = await crypto.subtle.decrypt(
          {
            name: "AES-GCM",
            iv: bytes.subarray(0, 12) as BufferSource,
            additionalData: encoder.encode(id),
          },
          boxKey,
          bytes.subarray(12) as BufferSource,
        );
        return passFrom(plain);
      } catch {
        return null;
      }
    },
  };
}

/** A fresh request: a new one-time key pair that never leaves this tab. */
export async function newLinkRequest(): Promise<LinkRequest> {
  const pair = (await crypto.subtle.generateKey({ name: "X25519" }, false, [
    "deriveBits",
  ])) as CryptoKeyPair;
  return linkRequestFrom(pair, randomHex(16));
}
