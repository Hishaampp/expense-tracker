"use client";

import { useCallback, useEffect, useState } from "react";

/**
 * The page's query string as state: read once after the page mounts (the
 * site is static, so not while rendering), written back without a reload
 * so a filtered view can be bookmarked or linked to.
 */
export function useQueryState(): [URLSearchParams | null, (next: Record<string, string | null>) => void] {
  const [params, setParams] = useState<URLSearchParams | null>(null);
  useEffect(() => {
    // Reading the address is a one-off sync from the browser.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setParams(new URLSearchParams(window.location.search));
  }, []);
  const write = useCallback((next: Record<string, string | null>) => {
    const p = new URLSearchParams(window.location.search);
    for (const [k, v] of Object.entries(next)) {
      if (v === null || v === "") p.delete(k);
      else p.set(k, v);
    }
    const q = p.toString();
    window.history.replaceState(null, "", q ? `?${q}` : window.location.pathname);
    setParams(p);
  }, []);
  return [params, write];
}
