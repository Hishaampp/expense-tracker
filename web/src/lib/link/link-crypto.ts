/**
 * The website's half of "Link a computer" (W2). Ported against the app's
 * lib/data/sync/computer_link.dart: X25519 between this tab's one-time key
 * and the phone's one-time key, HKDF-SHA-256 ("ample-link-v1") to an
 * AES-256-GCM key, the request id as associated data.
 */

const encoder = new TextEncoder();

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

/** One request: the QR text to show, and how to open the phone's answer. */
export type LinkRequest = {
  id: string;
  qr: string;
  open: (phoneKey: string, sealed: string) => Promise<Uint8Array | null>;
};

/** Builds a request around an existing key pair (tests pass a fixed one). */
export async function linkRequestFrom(
  keyPair: CryptoKeyPair,
  id: string,
): Promise<LinkRequest> {
  const publicRaw = new Uint8Array(await crypto.subtle.exportKey("raw", keyPair.publicKey));
  return {
    id,
    qr: `AMPLE1:${id}:${base64UrlNoPad(publicRaw)}`,
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
          { name: "HKDF", hash: "SHA-256", salt: new Uint8Array(32), info: encoder.encode("ample-link-v1") },
          hkdf,
          { name: "AES-GCM", length: 256 },
          false,
          ["decrypt"],
        );
        const bytes = fromBase64(sealed);
        if (bytes.length < 12 + 16) return null;
        const key = await crypto.subtle.decrypt(
          {
            name: "AES-GCM",
            iv: bytes.subarray(0, 12) as BufferSource,
            additionalData: encoder.encode(id),
          },
          boxKey,
          bytes.subarray(12) as BufferSource,
        );
        const out = new Uint8Array(key);
        return out.length === 32 ? out : null;
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
