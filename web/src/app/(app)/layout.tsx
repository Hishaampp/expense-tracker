"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { Shell } from "@/components/shell/shell";
import { useVault } from "@/lib/vault/vault-context";

/** Dashboard pages need unlocked records; otherwise back to the front door. */
export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { state } = useVault();
  const router = useRouter();
  const open = state.status === "open";
  useEffect(() => {
    if (!open) router.replace("/");
  }, [open, router]);
  if (!open) return null;
  return <Shell>{children}</Shell>;
}
