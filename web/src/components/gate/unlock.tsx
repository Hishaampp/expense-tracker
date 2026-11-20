"use client";

import { LogOut } from "lucide-react";
import { useState } from "react";
import { ScanUnlock } from "@/components/link/scan-unlock";
import { cloud } from "@/lib/cloud/client";
import type { PhonePass } from "@/lib/link/link-crypto";
import { REMEMBER_DAYS } from "@/lib/vault/remember";
import type { UnlockFailure } from "@/lib/vault/vault-context";

const FAILURE_TEXT: Record<UnlockFailure, string> = {
  "wrong-key": "That phone's key doesn't open the records in this account. Scan with the phone you use Ample on.",
  empty: "This account has no synced records yet. On your phone, open Settings → Account & sync and let it finish syncing, then scan again.",
  network: "Couldn't reach your records. Check your connection and scan again.",
  forgotten: "The key saved on this computer no longer opens your records (sync may have been started over on your phone), so it was removed. Scan with your phone again.",
  "sign-in": "Couldn't sign this computer in. Scan the new code again; if it keeps happening, update Ample on your phone.",
};

/**
 * The only way in: scan with Ample on a signed-in phone. That one scan
 * signs this computer in and unlocks the records; there is no email,
 * Google or recovery-code sign-in on the website.
 */
export function Unlock({
  email,
  failure,
  onPass,
}: {
  /** Who this computer is signed in as, or null. */
  email: string | null;
  failure?: UnlockFailure;
  onPass: (pass: PhonePass, remember: boolean) => void;
}) {
  const [remember, setRemember] = useState(true);
  return (
    <div>
      <h1 className="rise font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em]">{email ? "Unlock with your phone" : "Sign in with your phone"}</h1>
      <p className="rise mt-5 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
        Scan this code with Ample on your phone. That signs this computer in and opens your records, sealed until they reach your browser.
      </p>

      {failure && (
        <p role="alert" className="mt-6 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink">
          {FAILURE_TEXT[failure]}
        </p>
      )}

      <div className="rise mt-8" style={{ "--i": 2 } as React.CSSProperties}>
        <ScanUnlock onPass={(pass) => onPass(pass, remember)} />
      </div>

      <label className="rise mt-6 flex cursor-pointer items-start gap-3 rounded-2xl border border-line p-4 transition-colors hover:bg-raised" style={{ "--i": 3 } as React.CSSProperties}>
        <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} className="mt-0.5 size-[18px] shrink-0 accent-[var(--honey)]" />
        <span className="grid gap-0.5">
          <span className="text-[0.9375rem] font-semibold">Keep this computer unlocked for {REMEMBER_DAYS} days</span>
          <span className="text-[0.8125rem] leading-relaxed text-ink-muted">Opens straight to your records next time, without a scan. Leave it off on a shared or office computer.</span>
        </span>
      </label>

      {email && (
        <div className="rise mt-10 flex flex-wrap items-center justify-between gap-3 border-t border-line pt-6 text-[0.875rem] text-ink-muted" style={{ "--i": 4 } as React.CSSProperties}>
          <span className="min-w-0 truncate">
            Signed in as <span className="font-semibold text-ink">{email}</span>
          </span>
          <button type="button" onClick={() => cloud().auth.signOut()} className="inline-flex items-center gap-1.5 font-semibold text-honey-text hover:underline">
            <LogOut className="size-4" aria-hidden /> Sign out
          </button>
        </div>
      )}
    </div>
  );
}
