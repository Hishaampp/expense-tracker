import { describe, expect, it } from "vitest";
import vectors from "./fixtures/link-vectors.json";
import { linkRequestFrom, newLinkRequest } from "./link-crypto";

const b64url = (bytes: number[]) =>
  Buffer.from(bytes).toString("base64").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

// Sealed by the app's own code: test/data/sync/computer_link_test.dart.
async function webKeys(): Promise<CryptoKeyPair> {
  const jwk = { kty: "OKP", crv: "X25519", d: b64url(vectors.webSeed), x: b64url(vectors.webPublic) };
  const privateKey = await crypto.subtle.importKey("jwk", jwk, { name: "X25519" }, false, ["deriveBits"]);
  const publicKey = await crypto.subtle.importKey("jwk", { kty: "OKP", crv: "X25519", x: jwk.x }, { name: "X25519" }, true, []);
  return { privateKey, publicKey };
}

describe("link crypto", () => {
  it("shows the same QR the app reads", async () => {
    const request = await linkRequestFrom(await webKeys(), vectors.id);
    expect(request.qr).toBe(vectors.qr);
  });

  it("opens the key and the sign-in the app sealed for this tab", async () => {
    const request = await linkRequestFrom(await webKeys(), vectors.id);
    const pass = await request.open(vectors.phoneKey, vectors.sealed);
    expect(Array.from(pass!.key)).toEqual(vectors.keyBytes);
    expect(pass!.email).toBe(vectors.email);
    expect(pass!.tokenHash).toBe(vectors.tokenHash);
  });

  it("refuses it under another request id or another tab's key", async () => {
    const swapped = await linkRequestFrom(await webKeys(), "f".repeat(32));
    expect(await swapped.open(vectors.phoneKey, vectors.sealed)).toBeNull();
    const other = await newLinkRequest();
    expect(await other.open(vectors.phoneKey, vectors.sealed)).toBeNull();
    expect(other.qr).toMatch(/^AMPLE2:[0-9a-f]{32}:[A-Za-z0-9_-]{43}$/);
  });
});
