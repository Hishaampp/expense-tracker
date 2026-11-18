"use client";

import { RotateCw, Smartphone } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { cloud } from "@/lib/cloud/client";
import { newLinkRequest, type LinkRequest, type PhonePass } from "@/lib/link/link-crypto";
import { AmpleQr } from "./ample-qr";

/** How long one code is good for; the server forgets answers after two minutes. */
const CODE_LIFETIME_MS = 110_000;
const POLL_MS = 1_500;

type Problem = "not-set-up" | "unreadable" | null;

/**
 * The way in: shows a one-time QR, waits for a signed-in phone to leave
 * its sealed pass (the sync key and a one-time sign-in), opens it here and
 * hands it to [onPass]. Works signed out: the pass is collected with the
 * request id only this tab knows. A new code is made before the old one
 * expires.
 */
export function ScanUnlock({ onPass }: { onPass: (pass: PhonePass) => void }) {
  const [request, setRequest] = useState<LinkRequest | null>(null);
  const [madeAt, setMadeAt] = useState(0);
  const [problem, setProblem] = useState<Problem>(null);
  const [now, setNow] = useState(0);
  const done = useRef(false);

  const fresh = useCallback(async () => {
    const next = await newLinkRequest();
    setRequest(next);
    setMadeAt(Date.now());
  }, []);

  useEffect(() => {
    let active = true;
    newLinkRequest().then((first) => {
      if (!active) return;
      setRequest(first);
      setMadeAt(Date.now());
    });
    return () => {
      active = false;
    };
  }, []);

  // Wait for the phone's answer; replace the code before it expires.
  useEffect(() => {
    if (!request) return;
    let stopped = false;
    const tick = async () => {
      if (stopped || done.current || document.hidden) return;
      setNow(Date.now());
      if (Date.now() - madeAt > CODE_LIFETIME_MS) {
        void fresh();
        return;
      }
      // Collecting removes it from the server in the same step.
      const { data, error } = await cloud().rpc("claim_link_request", { request_id: request.id });
      if (stopped) return;
      if (error) {
        // The function is missing until the migration runs in Supabase.
        if (error.code === "PGRST202" || error.code === "42883") setProblem("not-set-up");
        return;
      }
      const row = Array.isArray(data) ? data[0] : null;
      if (!row) return;
      const pass = await request.open(row.phone_key, row.sealed);
      if (!pass) {
        setProblem("unreadable");
        void fresh();
        return;
      }
      done.current = true;
      onPass(pass);
    };
    const timer = window.setInterval(() => void tick(), POLL_MS);
    return () => {
      stopped = true;
      window.clearInterval(timer);
    };
  }, [request, madeAt, fresh, onPass]);

  const left = request && now ? Math.max(0, 1 - (now - madeAt) / CODE_LIFETIME_MS) : 1;

  return (
    <div className="grid gap-6">
      <div className="grid justify-items-center gap-4 rounded-[1.5rem] border border-line bg-sunken p-6">
        <div className="relative">
          {request ? (
            <div key={request.id} className="rise">
              <AmpleQr text={request.qr} size={232} label="Code to scan with the Ample app on your phone" />
            </div>
          ) : (
            <div className="size-[232px] animate-pulse rounded-[1.25rem] bg-line" aria-hidden />
          )}
        </div>
        {/* Time left on this code: a honey line that drains. */}
        <div className="h-1 w-[232px] overflow-hidden rounded-full bg-line" aria-hidden>
          <div className="h-full origin-left rounded-full bg-honey transition-transform duration-[1500ms] ease-linear" style={{ transform: `scaleX(${left})` }} />
        </div>
        <p className="flex items-center gap-2 text-[0.875rem] text-ink-muted" aria-live="polite">
          <span className="relative flex size-2">
            <span className="absolute inset-0 animate-ping rounded-full bg-honey opacity-60" />
            <span className="relative size-2 rounded-full bg-honey" />
          </span>
          Waiting for your phone
        </p>
      </div>

      <ol className="grid gap-3 text-[0.9375rem] leading-relaxed text-ink-muted">
        {[
          "Open Ample on your phone.",
          "Go to Settings → Account & sync → Link a computer.",
          "Point the camera at this code and confirm.",
        ].map((step, i) => (
          <li key={step} className="flex gap-3">
            <span className="tabular grid size-6 shrink-0 place-items-center rounded-full bg-honey-soft text-[0.75rem] font-bold text-honey-text">{i + 1}</span>
            <span className={i === 1 ? "font-semibold text-ink" : undefined}>{step}</span>
          </li>
        ))}
      </ol>

      {problem === "not-set-up" && (
        <p role="alert" className="rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink">
          Signing in with your phone isn&apos;t switched on for this server yet.
        </p>
      )}
      {problem === "unreadable" && (
        <p role="alert" className="flex items-start gap-2 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink">
          <RotateCw className="mt-1 size-4 shrink-0" aria-hidden />
          That answer couldn&apos;t be opened here. A new code is ready; scan it again.
        </p>
      )}
      <p className="flex items-start gap-2 text-[0.8125rem] leading-relaxed text-ink-faint">
        <Smartphone className="mt-0.5 size-4 shrink-0" aria-hidden />
        Only a phone signed in to Ample, with Account & sync on, can sign a computer in. Update Ample on your phone if it says the code isn&apos;t an Ample code.
      </p>
    </div>
  );
}
