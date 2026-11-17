"use client";

import { createContext, useCallback, useContext, useEffect, useRef, useState } from "react";
import { cloud } from "@/lib/cloud/client";
import { CloudError, fetchSealedRecords } from "@/lib/cloud/records";
import { SyncCrypto } from "@/lib/crypto/sync-crypto";
import { openVault, type Vault } from "./vault";

/** How long the records stay unlocked without use. */
export const IDLE_LOCK_MS = 15 * 60 * 1000;

export type UnlockFailure = "wrong-key" | "empty" | "network";

export type VaultState =
  | { status: "locked"; failure?: UnlockFailure }
  | { status: "opening"; phase: "download" | "unlock"; done: number; total: number }
  | { status: "open"; vault: Vault; lockAt: number };

type VaultApi = {
  state: VaultState;
  unlock: (key: Uint8Array) => Promise<void>;
  lock: () => void;
};

const VaultContext = createContext<VaultApi>({
  state: { status: "locked" },
  unlock: async () => {},
  lock: () => {},
});

/**
 * Holds the unlocked records in this tab's memory only. Nothing readable
 * goes to storage or the URL; a reload, closing the tab, 15 minutes idle
 * or Lock forgets it all.
 */
export function VaultProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<VaultState>({ status: "locked" });
  const lockAt = useRef(0);

  const lock = useCallback(() => setState({ status: "locked" }), []);

  const unlock = useCallback(async (key: Uint8Array) => {
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
      const vault = await openVault(records, crypto, (done, total) =>
        setState({ status: "opening", phase: "unlock", done, total }),
      );
      if (vault.opened === 0) {
        setState({ status: "locked", failure: "wrong-key" });
        return;
      }
      lockAt.current = Date.now() + IDLE_LOCK_MS;
      setState({ status: "open", vault, lockAt: lockAt.current });
    } catch (error) {
      if (!(error instanceof CloudError) && !(error instanceof TypeError)) throw error;
      setState({ status: "locked", failure: "network" });
    }
  }, []);

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

  return <VaultContext.Provider value={{ state, unlock, lock }}>{children}</VaultContext.Provider>;
}

export const useVault = () => useContext(VaultContext);
