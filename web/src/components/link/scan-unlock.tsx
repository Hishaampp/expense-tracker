"use client";

import { RotateCw, Smartphone } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { cloud } from "@/lib/cloud/client";
import { newLinkRequest, type LinkRequest } from "@/lib/link/link-crypto";
import { AmpleQr } from "./ample-qr";

/** How long one code is good for; the server forgets answers after two minutes. */
const CODE_LIFETIME_MS = 110_000;
const POLL_MS = 1_500;

type Problem = "not-set-up" | "unreadable" | null;

/**
 * Unlock by scanning: shows a one-time QR, waits for this account's phone
 * to leave the sealed key, opens it here and hands it to [onUnlock]. A new
 * code is made before the old one expires.
 */
export function ScanUnlock({ onUnlock }: { onUnlock: (key: Uint8Array) => void }) {
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
      const { data, error } = await cloud()
        .from("link_requests")
        .select("phone_key, sealed")
        .eq("id", request.id)
        .maybeSingle();
      if (stopped) return;
      if (error) {
        // The table is missing until the migration runs in Supabase.
        if (error.code === "PGRST205" || error.code === "42P01") setProblem("not-set-up");
        return;
      }
      if (!data) return;
      const key = await request.open(data.phone_key, data.sealed);
      // Supabase sends a request only when it is awaited. The server forgets
      // it after two minutes anyway; this clears it at once.
      await cloud().from("link_requests").delete().eq("id", request.id);
      if (!key) {
        setProblem("unreadable");
        void fresh();
        return;
      }
      done.current = true;
      onUnlock(key);
    };
    const timer = window.setInterval(() => void tick(), POLL_MS);
    return () => {
      stopped = true;
      window.clearInterval(timer);
    };
  }, [request, madeAt, fresh, onUnlock]);

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
          Scan unlock isn&apos;t switched on for this server yet. Use your recovery code for now.
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
        Your phone must be signed in to this same account with Account & sync on.
      </p>
    </div>
  );
}
