"use client";

import { Check, KeyRound, LogOut, QrCode } from "lucide-react";
import { useMemo, useState } from "react";
import { ScanUnlock } from "@/components/link/scan-unlock";
import { REMEMBER_DAYS } from "@/lib/vault/remember";
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
  forgotten: "The key saved on this computer no longer opens your records (sync may have been started over on your phone), so it was removed. Scan with your phone again.",
};

/** Unlock by scanning with the phone (first) or by typing the recovery code. */
export function Unlock({
  email,
  failure,
  onUnlock,
}: {
  email: string;
  failure?: UnlockFailure;
  onUnlock: (key: Uint8Array, remember: boolean) => void;
}) {
  const [method, setMethod] = useState<"scan" | "code">("scan");
  const [remember, setRemember] = useState(true);
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
        Your records reach this computer sealed and open only here, in your browser. Scan with your phone, or type your recovery code.
      </p>

      <div role="tablist" aria-label="How to unlock" className="rise mt-9 grid grid-cols-2 rounded-full bg-sunken p-1 text-[0.875rem] font-semibold" style={{ "--i": 2 } as React.CSSProperties}>
        {(
          [
            { id: "scan", label: "Scan with phone", Icon: QrCode },
            { id: "code", label: "Recovery code", Icon: KeyRound },
          ] as const
        ).map(({ id, label, Icon }) => (
          <button
            key={id}
            type="button"
            role="tab"
            id={`tab-${id}`}
            aria-selected={method === id}
            aria-controls={`panel-${id}`}
            onClick={() => setMethod(id)}
            className={`relative flex h-10 items-center justify-center gap-2 rounded-full transition-colors ${
              method === id ? "bg-raised text-ink shadow-[var(--shadow-near)]" : "text-ink-muted hover:text-ink"
            }`}
          >
            <Icon className="size-4" aria-hidden />
            {label}
          </button>
        ))}
      </div>

      {failure && method === "scan" && (
        <p role="alert" className="mt-6 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink">
          {FAILURE_TEXT[failure]}
        </p>
      )}

      {method === "scan" ? (
        <div id="panel-scan" role="tabpanel" aria-labelledby="tab-scan" className="rise mt-8" style={{ "--i": 3 } as React.CSSProperties}>
          <ScanUnlock onUnlock={(k) => onUnlock(k, remember)} />
        </div>
      ) : (
      <form
        id="panel-code"
        role="tabpanel"
        aria-labelledby="tab-code"
        className="rise mt-8 grid gap-3"
        style={{ "--i": 3 } as React.CSSProperties}
        onSubmit={(e) => {
          e.preventDefault();
          if (key) onUnlock(key, remember);
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
      )}

      <label className="rise mt-6 flex cursor-pointer items-start gap-3 rounded-2xl border border-line p-4 transition-colors hover:bg-raised" style={{ "--i": 4 } as React.CSSProperties}>
        <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} className="mt-0.5 size-[18px] shrink-0 accent-[var(--honey)]" />
        <span className="grid gap-0.5">
          <span className="text-[0.9375rem] font-semibold">Keep this computer unlocked for {REMEMBER_DAYS} days</span>
          <span className="text-[0.8125rem] leading-relaxed text-ink-muted">Opens straight to your records next time, without a scan. Leave it off on a shared or office computer.</span>
        </span>
      </label>

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
