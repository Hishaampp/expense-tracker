import { describe, expect, it } from "vitest";
import { MemoryDeviceStore, recallKey, rememberedUntil, rememberKey } from "./remember";

const key = Uint8Array.from({ length: 32 }, (_, i) => i * 3);
const now = Date.UTC(2026, 10, 19);

describe("remember this computer", () => {
  it("gives the key back to the same account until it runs out", async () => {
    const store = new MemoryDeviceStore();
    const until = await rememberKey(store, "user-1", key, now);
    expect(until).toBe(now + 30 * 86_400_000);
    expect(Array.from((await recallKey(store, "user-1", now + 1000))!.key)).toEqual(Array.from(key));
    expect(await rememberedUntil(store, "user-1", now)).toBe(until);
  });

  it("never stores the key as it is, and can't read the wrapping key out", async () => {
    const store = new MemoryDeviceStore();
    await rememberKey(store, "user-1", key, now);
    const v = store.value!;
    expect(Array.from(v.sealed)).not.toEqual(Array.from(key));
    expect(v.wrapKey.extractable).toBe(false);
    await expect(crypto.subtle.exportKey("raw", v.wrapKey)).rejects.toThrow();
  });

  it("forgets it for another account, after 30 days, or when tampered with", async () => {
    const other = new MemoryDeviceStore();
    await rememberKey(other, "user-1", key, now);
    expect(await recallKey(other, "user-2", now)).toBeNull();
    expect(other.value).toBeNull();

    const old = new MemoryDeviceStore();
    await rememberKey(old, "user-1", key, now);
    expect(await recallKey(old, "user-1", now + 30 * 86_400_000)).toBeNull();
    expect(old.value).toBeNull();

    const bent = new MemoryDeviceStore();
    await rememberKey(bent, "user-1", key, now);
    bent.value!.sealed[0] ^= 1;
    expect(await recallKey(bent, "user-1", now)).toBeNull();
    expect(bent.value).toBeNull();
  });
});
