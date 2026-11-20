/**
 * "Keep this computer unlocked": the sync key kept in this browser so the
 * dashboard opens without a scan, for a fixed time.
 *
 * The key is never stored as it is. It is sealed (AES-256-GCM, the account
 * id as associated data) with a wrapping key the browser makes
 * non-extractable: the wrapping key can be used here but never read out,
 * so the stored blob can't be copied to another computer and opened. Both
 * live in IndexedDB (a CryptoKey can be stored there, a string can't hold
 * it). Anyone using this browser profile can still open the records while
 * it is remembered; the unlock screen says so.
 */

export const REMEMBER_DAYS = 30;
const DAY_MS = 86_400_000;

export type Remembered = {
  userId: string;
  wrapKey: CryptoKey;
  iv: Uint8Array;
  sealed: Uint8Array;
  until: number;
};

/** Where the remembered key lives: IndexedDB in the browser, memory in tests. */
export interface DeviceStore {
  get(): Promise<Remembered | null>;
  put(value: Remembered): Promise<void>;
  clear(): Promise<void>;
}

const encoder = new TextEncoder();

export async function rememberKey(store: DeviceStore, userId: string, key: Uint8Array, now = Date.now(), days = REMEMBER_DAYS): Promise<number> {
  const wrapKey = await crypto.subtle.generateKey({ name: "AES-GCM", length: 256 }, false, ["encrypt", "decrypt"]);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const sealed = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv: iv as BufferSource, additionalData: encoder.encode(userId) }, wrapKey, key as BufferSource));
  const until = now + days * DAY_MS;
  await store.put({ userId, wrapKey, iv, sealed, until });
  return until;
}

/**
 * The remembered key for [userId], or null. A key for another account, an
 * expired one or one that won't open is cleared.
 */
export async function recallKey(store: DeviceStore, userId: string, now = Date.now()): Promise<{ key: Uint8Array; until: number } | null> {
  const r = await store.get();
  if (!r) return null;
  if (r.userId !== userId || r.until <= now) {
    await store.clear();
    return null;
  }
  try {
    const plain = await crypto.subtle.decrypt({ name: "AES-GCM", iv: r.iv as BufferSource, additionalData: encoder.encode(userId) }, r.wrapKey, r.sealed as BufferSource);
    return { key: new Uint8Array(plain), until: r.until };
  } catch {
    await store.clear();
    return null;
  }
}

/** When the remembered key for [userId] runs out, without opening it. */
export async function rememberedUntil(store: DeviceStore, userId: string, now = Date.now()): Promise<number | null> {
  const r = await store.get();
  return r && r.userId === userId && r.until > now ? r.until : null;
}

export class MemoryDeviceStore implements DeviceStore {
  value: Remembered | null = null;
  async get() {
    return this.value;
  }
  async put(v: Remembered) {
    this.value = v;
  }
  async clear() {
    this.value = null;
  }
}

const DB = "ample";
const STORE = "device";
const ID = "remembered-key";

function db(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB, 1);
    req.onupgradeneeded = () => req.result.createObjectStore(STORE);
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

function run<T>(mode: IDBTransactionMode, act: (s: IDBObjectStore) => IDBRequest<T>): Promise<T> {
  return db().then(
    (d) =>
      new Promise<T>((resolve, reject) => {
        const tx = d.transaction(STORE, mode);
        const req = act(tx.objectStore(STORE));
        tx.oncomplete = () => {
          d.close();
          resolve(req.result);
        };
        tx.onerror = () => {
          d.close();
          reject(tx.error);
        };
      }),
  );
}

/**
 * IndexedDB. A private window or blocked storage just means nothing is
 * remembered: every call degrades to "no key" instead of failing.
 */
export const browserDeviceStore: DeviceStore = {
  async get() {
    try {
      return ((await run("readonly", (s) => s.get(ID))) as Remembered | undefined) ?? null;
    } catch {
      return null;
    }
  },
  async put(v) {
    try {
      await run("readwrite", (s) => s.put(v, ID));
    } catch {
      // Not remembered; the next visit asks for a scan again.
    }
  },
  async clear() {
    try {
      await run("readwrite", (s) => s.delete(ID));
    } catch {
      // Nothing stored to clear.
    }
  },
};
