"use client";

import { LockKeyholeOpen } from "lucide-react";
import { formatDate } from "@/lib/format/format";

/**
 * After Lock or the idle lock on a remembered computer: one click opens the
 * records again, no scan. Forgetting brings back the scan or code.
 */
export function WelcomeBack({ email, until, offline, onOpen, onForget }: { email: string; until: number; offline?: boolean; onOpen: () => void; onForget: () => void }) {
  return (
    <div>
      <h1 className="rise font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em]">Welcome back</h1>
      <p className="rise mt-5 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
        {offline ? "Your records are ready to open" : "Your records were locked"}. This computer is remembered for {email} until {formatDate(until)}, so they open without a scan.
      </p>
      {offline && (
        <p role="alert" className="rise mt-6 rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] leading-relaxed text-ink" style={{ "--i": 2 } as React.CSSProperties}>
          Couldn&apos;t reach your records. Check your connection, then try again.
        </p>
      )}
      <button
        type="button"
        autoFocus
        onClick={onOpen}
        className="rise mt-9 inline-flex h-12 w-full items-center justify-center gap-2 rounded-full bg-fill text-[1rem] font-semibold text-on-fill shadow-[var(--shadow-near)] transition-transform hover:-translate-y-px active:translate-y-0"
        style={{ "--i": 2 } as React.CSSProperties}
      >
        <LockKeyholeOpen className="size-[18px]" aria-hidden /> {offline ? "Try again" : "Open my records"}
      </button>
      <button
        type="button"
        onClick={onForget}
        className="rise mt-3 h-11 w-full rounded-full text-[0.9375rem] font-semibold text-ink-muted transition-colors hover:bg-raised hover:text-ink"
        style={{ "--i": 3 } as React.CSSProperties}
      >
        Forget this computer
      </button>
    </div>
  );
}
