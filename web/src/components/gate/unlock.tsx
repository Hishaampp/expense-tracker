"use client";

import { Check, KeyRound, LogOut, QrCode } from "lucide-react";
import { useMemo, useState } from "react";
import { cloud } from "@/lib/cloud/client";
import {
  formatRecoveryCode,
  keyFromRecoveryCode,
  normalizeRecoveryCode,
  RECOVERY_CODE_LENGTH,
} from "@/lib/crypto/sync-key";
import type { UnlockFailure } from "@/lib/vault/vault-context";

const GROUPS = Math.ceil(RECOVERY_CODE_LENGTH / 4);

const FAILURE_TEXT: Record<UnlockFailure, string> = {
  "wrong-key":
    "That code is valid, but it doesn't open the records in this account. Use the code from the phone signed in as this account.",
  empty:
    "This account has no synced records yet. On your phone, open Settings → Account & sync and let it finish syncing, then try again.",
  network: "Couldn't reach your records. Check your connection and try again.",
};

/** Unlock with the recovery code (QR from the phone comes in the next step). */
export function Unlock({
  email,
  failure,
  onUnlock,
}: {
  email: string;
  failure?: UnlockFailure;
  onUnlock: (key: Uint8Array) => void;
}) {
  const [code, setCode] = useState("");
  const clean = normalizeRecoveryCode(code);
  const complete = clean.length === RECOVERY_CODE_LENGTH;
  const key = useMemo(() => (complete ? keyFromRecoveryCode(clean) : null), [clean, complete]);
  const typo = complete && !key;
  const filledGroups = Math.floor(clean.length / 4) + (clean.length % 4 ? 1 : 0);

  return (
    <div>
      <h1 className="rise font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em]">Unlock your records</h1>
      <p className="rise mt-5 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
        Your records reach this computer sealed. Your recovery code opens them here, in this tab only. It never leaves this computer.
      </p>

      <div role="tablist" aria-label="How to unlock" className="rise mt-9 grid grid-cols-2 rounded-full bg-sunken p-1 text-[0.875rem] font-semibold" style={{ "--i": 2 } as React.CSSProperties}>
        <button role="tab" aria-selected className="flex h-10 items-center justify-center gap-2 rounded-full bg-raised text-ink shadow-[var(--shadow-near)]">
          <KeyRound className="size-4" aria-hidden />
          Recovery code
        </button>
        <button role="tab" aria-selected={false} disabled className="flex h-10 cursor-not-allowed items-center justify-center gap-2 rounded-full text-ink-faint">
          <QrCode className="size-4" aria-hidden />
          Scan with phone
          <span className="rounded-full border border-line px-1.5 py-px text-[0.6875rem] font-semibold">Soon</span>
        </button>
      </div>

      <form
        className="rise mt-8 grid gap-3"
        style={{ "--i": 3 } as React.CSSProperties}
        onSubmit={(e) => {
          e.preventDefault();
          if (key) onUnlock(key);
        }}
      >
        <label htmlFor="code" className="text-[0.875rem] font-semibold">
          Recovery code
        </label>
        <textarea
          id="code"
          rows={3}
          spellCheck={false}
          autoComplete="off"
          autoCapitalize="characters"
          value={formatRecoveryCode(code)}
          onChange={(e) => setCode(e.target.value)}
          placeholder="XXXX-XXXX-XXXX-…"
          aria-invalid={typo || failure === "wrong-key"}
          aria-describedby="code-help"
          className="resize-none rounded-xl border border-line-strong/70 bg-sunken px-4 py-3.5 font-mono text-[1.0625rem] leading-[1.65] tracking-[0.06em] text-ink uppercase placeholder:text-ink-faint focus:border-honey focus:outline-none aria-[invalid=true]:border-danger"
        />
        {/* Each group of four fills with honey as it is typed. */}
        <div className="flex gap-1" aria-hidden>
          {Array.from({ length: GROUPS }, (_, i) => (
            <span key={i} className="h-1 flex-1 overflow-hidden rounded-full bg-line">
              <span
                className="block h-full rounded-full bg-honey transition-transform duration-500 ease-[var(--ease-out-expo)]"
                style={{ transform: `scaleX(${i < filledGroups ? 1 : 0})`, transformOrigin: "left" }}
              />
            </span>
          ))}
        </div>
        <p id="code-help" className="min-h-[2.75rem] text-[0.875rem] leading-relaxed" aria-live="polite">
          {typo ? (
            <span className="text-danger">This code has a typo. Check each group against the one you wrote down.</span>
          ) : key ? (
            <span className="inline-flex items-center gap-1.5 font-semibold text-income">
              <Check className="size-4" aria-hidden /> Code looks right
            </span>
          ) : failure ? (
            <span className={failure === "wrong-key" ? "text-danger" : "text-ink"}>{FAILURE_TEXT[failure]}</span>
          ) : (
            <span className="text-ink-faint">
              {clean.length} of {RECOVERY_CODE_LENGTH} characters. On your phone: Settings → Account & sync → Show recovery code.
            </span>
          )}
        </p>
        <button
          type="submit"
          disabled={!key}
          className="mt-1 h-13 rounded-full bg-fill text-[0.9875rem] font-semibold text-on-fill shadow-[var(--shadow-near)] transition-[transform,box-shadow,opacity] duration-300 ease-[var(--ease-out-expo)] hover:-translate-y-px hover:shadow-[var(--shadow-far)] disabled:cursor-not-allowed disabled:opacity-35 disabled:hover:translate-y-0 disabled:hover:shadow-none"
        >
          Unlock
        </button>
      </form>

      <div className="rise mt-10 flex flex-wrap items-center justify-between gap-3 border-t border-line pt-6 text-[0.875rem] text-ink-muted" style={{ "--i": 4 } as React.CSSProperties}>
        <span className="min-w-0 truncate">
          Signed in as <span className="font-semibold text-ink">{email}</span>
        </span>
        <button type="button" onClick={() => cloud().auth.signOut()} className="inline-flex items-center gap-1.5 font-semibold text-honey-text hover:underline">
          <LogOut className="size-4" aria-hidden /> Switch account
        </button>
      </div>
    </div>
  );
}
