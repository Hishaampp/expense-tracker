"use client";

import { useMemo, useState } from "react";
import { useVault } from "@/lib/vault/vault-context";
import { transactionsOf } from "./overview";
import { itemsOf, lookupOf } from "./tables";

/**
 * The unlocked records ready for the dashboard's pages: every readable
 * transaction, joined to its names, and "now" fixed while the page is
 * open so numbers don't shift under the reader.
 */
export function useLedger() {
  const { state } = useVault();
  const vault = state.status === "open" ? state.vault : null;
  const [now] = useState(() => new Date());
  return useMemo(() => {
    if (!vault) return null;
    const txns = transactionsOf(vault);
    const lookup = lookupOf(vault);
    return { vault, txns, lookup, items: itemsOf(txns, lookup), now };
  }, [vault, now]);
}

export type Ledger = NonNullable<ReturnType<typeof useLedger>>;
