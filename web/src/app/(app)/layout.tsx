"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { AmpleMark } from "@/components/brand/ample-mark";
import { Shell } from "@/components/shell/shell";
import { useVault } from "@/lib/vault/vault-context";

/** Dashboard pages need unlocked records; otherwise back to the front door. */
export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { state, ready } = useVault();
  const router = useRouter();
  const open = state.status === "open";
  // A remembered computer opens the page it was asked for: wait while the key is tried.
  const waiting = !ready || state.status === "opening";
  useEffect(() => {
    if (!open && !waiting) router.replace("/");
  }, [open, waiting, router]);
  if (!open)
    return waiting ? (
      <div className="grid min-h-dvh place-items-center text-ink" aria-busy>
        <AmpleMark size={56} sway title="Opening your records" />
      </div>
    ) : null;
  return <Shell>{children}</Shell>;
}
