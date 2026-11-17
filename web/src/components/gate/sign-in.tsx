"use client";

import { ArrowRight, Loader2, MailCheck } from "lucide-react";
import { useState } from "react";
import { cloud, signInReturnUrl } from "@/lib/cloud/client";

type Stage =
  | { kind: "idle" }
  | { kind: "sending" }
  | { kind: "sent"; email: string }
  | { kind: "error"; message: string };

function GoogleG() {
  return (
    <svg viewBox="0 0 48 48" className="size-[18px]" aria-hidden>
      <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z" />
      <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z" />
      <path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z" />
      <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z" />
    </svg>
  );
}

/** Sign in with the same account as the app: Google, or an email link. */
export function SignIn() {
  const [email, setEmail] = useState("");
  const [stage, setStage] = useState<Stage>({ kind: "idle" });

  async function google() {
    const { error } = await cloud().auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: signInReturnUrl() },
    });
    if (error) setStage({ kind: "error", message: "Google sign-in didn't start. Try again in a moment." });
  }

  async function emailLink(event: React.FormEvent) {
    event.preventDefault();
    const address = email.trim();
    setStage({ kind: "sending" });
    const { error } = await cloud().auth.signInWithOtp({
      email: address,
      options: { emailRedirectTo: signInReturnUrl(), shouldCreateUser: false },
    });
    if (!error) return setStage({ kind: "sent", email: address });
    const unknown = /signups? not allowed|not found|otp_disabled/i.test(error.message);
    setStage({
      kind: "error",
      message: unknown
        ? "No Ample account uses this email. In the app, open Settings → Account & sync to create one first."
        : error.status === 429
          ? "Too many sign-in emails just now. Wait a minute, then try again."
          : "The email didn't send. Check your connection and try again.",
    });
  }

  if (stage.kind === "sent") {
    return (
      <div aria-live="polite">
        <MailCheck className="rise size-9 text-honey-text" strokeWidth={1.5} aria-hidden />
        <h1 className="rise mt-6 font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em]" style={{ "--i": 1 } as React.CSSProperties}>
          Check your inbox
        </h1>
        <p className="rise mt-4 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 2 } as React.CSSProperties}>
          We sent a sign-in link to <span className="font-semibold text-ink">{stage.email}</span>. Open it on this computer and you&apos;ll come straight back here.
        </p>
        <button
          type="button"
          onClick={() => setStage({ kind: "idle" })}
          className="rise mt-8 text-[0.9375rem] font-semibold text-honey-text underline decoration-honey/40 underline-offset-4 hover:decoration-honey"
          style={{ "--i": 3 } as React.CSSProperties}
        >
          Use a different email
        </button>
      </div>
    );
  }

  const sending = stage.kind === "sending";
  return (
    <div>
      <h1 className="rise font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em] text-balance sm:text-[3.1rem]">
        Your money, on a bigger screen.
      </h1>
      <p className="rise mt-5 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
        Sign in with your Ample account to see everything your phone records, with room to search, compare and export.
      </p>

      <div className="rise mt-10 grid gap-5" style={{ "--i": 2 } as React.CSSProperties}>
        <button
          type="button"
          onClick={google}
          className="group flex h-13 items-center justify-center gap-3 rounded-full bg-fill px-6 text-[0.9875rem] font-semibold text-on-fill shadow-[var(--shadow-near)] transition-[transform,box-shadow] duration-300 ease-[var(--ease-out-expo)] hover:-translate-y-px hover:shadow-[var(--shadow-far)] active:translate-y-0 active:scale-[0.99]"
        >
          <span className="grid size-7 place-items-center rounded-full bg-white">
            <GoogleG />
          </span>
          Continue with Google
        </button>

        <div className="flex items-center gap-4 text-[0.8125rem] text-ink-faint" aria-hidden>
          <span className="h-px flex-1 bg-line" />
          or
          <span className="h-px flex-1 bg-line" />
        </div>

        <form onSubmit={emailLink} className="grid gap-3" noValidate>
          <label htmlFor="email" className="text-[0.875rem] font-semibold">
            Email
          </label>
          <div className="flex gap-2">
            <input
              id="email"
              type="email"
              autoComplete="email"
              inputMode="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              aria-describedby={stage.kind === "error" ? "sign-in-error" : undefined}
              className="h-13 min-w-0 flex-1 rounded-xl border border-line-strong/70 bg-sunken px-4 text-[1rem] text-ink placeholder:text-ink-faint transition-colors focus:border-honey focus:outline-none"
            />
            <button
              type="submit"
              disabled={sending || !/^\S+@\S+\.\S+$/.test(email.trim())}
              aria-label="Email me a sign-in link"
              className="grid h-13 w-13 shrink-0 place-items-center rounded-xl bg-honey text-on-honey transition-[transform,opacity] duration-300 ease-[var(--ease-out-expo)] hover:scale-[1.03] active:scale-95 disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:scale-100"
            >
              {sending ? <Loader2 className="size-5 animate-spin" aria-hidden /> : <ArrowRight className="size-5" aria-hidden />}
            </button>
          </div>
          <p className="text-[0.8125rem] leading-relaxed text-ink-faint">We&apos;ll email you a link. No password.</p>
        </form>

        {stage.kind === "error" && (
          <p id="sign-in-error" role="alert" className="rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink">
            {stage.message}
          </p>
        )}
      </div>
    </div>
  );
}
