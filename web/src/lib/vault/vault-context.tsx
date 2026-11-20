"use client";

import { createContext, useCallback, useContext, useEffect, useRef, useState } from "react";
import { cloud } from "@/lib/cloud/client";
import { CloudError, fetchSealedRecords } from "@/lib/cloud/records";
import { SyncCrypto } from "@/lib/crypto/sync-crypto";
import { useSession } from "@/lib/session/session";
import { browserDeviceStore, recallKey, rememberedUntil, rememberKey } from "./remember";
import { openVault, type Vault } from "./vault";

/** How long the records stay unlocked without use. */
export const IDLE_LOCK_MS = 15 * 60 * 1000;

export type UnlockFailure = "wrong-key" | "empty" | "network" | "forgotten" | "sign-in";

export type VaultState =
  | { status: "locked"; failure?: UnlockFailure }
  | { status: "opening"; phase: "download" | "unlock"; done: number; total: number }
  | { status: "open"; vault: Vault; lockAt: number };

type VaultApi = {
  state: VaultState;
  /**
   * Opens the records with [key]; [remember] keeps it on this computer for
   * [asUser] (the account just signed in, before the session has caught up).
   */
  unlock: (key: Uint8Array, remember?: boolean, asUser?: string) => Promise<void>;
  /** Shows that signing this computer in failed. */
  fail: (failure: UnlockFailure) => void;
  lock: () => void;
  /** Until when this computer is remembered, or null. */
  remembered: number | null;
  /** False until a remembered key has been tried on this page load. */
  ready: boolean;
  /** Opens with the key remembered on this computer (one click after a lock). */
  unlockRemembered: () => Promise<void>;
  /** Removes the key kept on this computer. */
  forget: () => Promise<void>;
};

const VaultContext = createContext<VaultApi>({
  state: { status: "locked" },
  unlock: async () => {},
  fail: () => {},
  lock: () => {},
  remembered: null,
  ready: true,
  unlockRemembered: async () => {},
  forget: async () => {},
});

/**
 * Holds the unlocked records in this tab's memory only; nothing readable
 * goes to storage or the URL. 15 minutes idle or Lock closes them. When
 * the person chose to keep this computer unlocked, the key (sealed, see
 * remember.ts) opens them again on the next visit without a scan.
 */
export function VaultProvider({ children }: { children: React.ReactNode }) {
  const session = useSession();
  const userId = session.status === "signed-in" ? session.session.user.id : null;
  const [state, setState] = useState<VaultState>({ status: "locked" });
  const [remembered, setRemembered] = useState<number | null>(null);
  const [ready, setReady] = useState(false);
  const tried = useRef(false);
  const lockAt = useRef(0);

  const lock = useCallback(() => setState({ status: "locked" }), []);

  const forget = useCallback(async () => {
    await browserDeviceStore.clear();
    setRemembered(null);
  }, []);

  const openWith = useCallback(async (key: Uint8Array, opts: { remember?: boolean; fromDevice?: boolean; asUser?: string }) => {
    setState({ status: "opening", phase: "download", done: 0, total: 0 });
    try {
      const [crypto, records] = await Promise.all([
        SyncCrypto.create(key),
        fetchSealedRecords(cloud(), (loaded) =>
          setState({ status: "opening", phase: "download", done: loaded, total: 0 }),
        ),
      ]);
      if (records.length === 0) {
        setState({ status: "locked", failure: "empty" });
        return;
      }
      // A key that no longer opens anything (sync was started over) is forgotten.
      const stale = async () => {
        if (!opts.fromDevice) return false;
        await browserDeviceStore.clear();
        setRemembered(null);
        setState({ status: "locked", failure: "forgotten" });
        return true;
      };
      const vault = await openVault(records, crypto, (done, total) =>
        setState({ status: "opening", phase: "unlock", done, total }),
      );
      if (vault.opened === 0) {
        if (!(await stale())) setState({ status: "locked", failure: "wrong-key" });
        return;
      }
      const owner = opts.asUser ?? userId;
      if (opts.remember && owner) setRemembered(await rememberKey(browserDeviceStore, owner, key));
      lockAt.current = Date.now() + IDLE_LOCK_MS;
      setState({ status: "open", vault, lockAt: lockAt.current });
    } catch (error) {
      if (!(error instanceof CloudError) && !(error instanceof TypeError)) throw error;
      setState({ status: "locked", failure: "network" });
    }
  }, [userId]);

  const unlock = useCallback((key: Uint8Array, remember = false, asUser?: string) => openWith(key, { remember, asUser }), [openWith]);
  const fail = useCallback((failure: UnlockFailure) => setState({ status: "locked", failure }), []);

  const unlockRemembered = useCallback(async () => {
    if (!userId) return;
    const r = await recallKey(browserDeviceStore, userId);
    if (!r) {
      setRemembered(null);
      return;
    }
    await openWith(r.key, { fromDevice: true });
  }, [userId, openWith]);

  // On each visit, once signed in: open with the remembered key, if any.
  // Signing out forgets it.
  useEffect(() => {
    if (session.status === "loading") return;
    if (!userId) {
      tried.current = false;
      void browserDeviceStore.clear().then(() => {
        setRemembered(null);
        setReady(true);
      });
      return;
    }
    if (tried.current) return;
    tried.current = true;
    void (async () => {
      const until = await rememberedUntil(browserDeviceStore, userId);
      setRemembered(until);
      if (until) await unlockRemembered();
      setReady(true);
    })();
  }, [session.status, userId, unlockRemembered]);

  // Any use pushes the idle lock back; a timer checks it.
  const open = state.status === "open";
  useEffect(() => {
    if (!open) return;
    let last = 0;
    const bump = () => {
      const now = Date.now();
      if (now - last < 15_000) return;
      last = now;
      lockAt.current = now + IDLE_LOCK_MS;
      setState((s) => (s.status === "open" ? { ...s, lockAt: lockAt.current } : s));
    };
    const events = ["pointerdown", "keydown", "wheel", "pointermove"] as const;
    events.forEach((e) => window.addEventListener(e, bump, { passive: true }));
    const timer = window.setInterval(() => {
      if (Date.now() >= lockAt.current) setState({ status: "locked" });
    }, 5_000);
    return () => {
      events.forEach((e) => window.removeEventListener(e, bump));
      window.clearInterval(timer);
    };
  }, [open]);

  return <VaultContext.Provider value={{ state, unlock, fail, lock, remembered, ready, unlockRemembered, forget }}>{children}</VaultContext.Provider>;
}

export const useVault = () => useContext(VaultContext);
