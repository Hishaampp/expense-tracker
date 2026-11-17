import { Check, Loader2 } from "lucide-react";
import { formatCount } from "@/lib/format/format";

/** The steps while records arrive and open; the brand side fills the bowl. */
export function Unlocking({ phase, done, total }: { phase: "download" | "unlock"; done: number; total: number }) {
  const steps = [
    {
      label: "Fetching your sealed records",
      detail: phase === "download" ? `${formatCount(done)} received` : `${formatCount(total)} received`,
      state: phase === "download" ? "active" : "done",
    },
    {
      label: "Unlocking them in this tab",
      detail: phase === "unlock" ? `${formatCount(done)} of ${formatCount(total)}` : "Waiting",
      state: phase === "unlock" ? "active" : "waiting",
    },
  ] as const;
  return (
    <div aria-live="polite">
      <h1 className="rise font-display text-[2.6rem] leading-[1.05] tracking-[-0.02em]">Opening your records</h1>
      <p className="rise mt-5 text-[1.0625rem] leading-relaxed text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
        Every record is opened here, on this computer. Nothing readable is sent anywhere.
      </p>
      <ol className="mt-10 grid gap-5">
        {steps.map((s, i) => (
          <li key={s.label} className="rise flex items-center gap-4" style={{ "--i": i + 2 } as React.CSSProperties}>
            <span
              className={`grid size-9 shrink-0 place-items-center rounded-full ${
                s.state === "done" ? "bg-honey text-on-honey" : s.state === "active" ? "bg-honey-soft text-honey-text" : "bg-sunken text-ink-faint"
              }`}
            >
              {s.state === "done" ? <Check className="size-4" aria-hidden /> : s.state === "active" ? <Loader2 className="size-4 animate-spin" aria-hidden /> : <span className="size-1.5 rounded-full bg-current" />}
            </span>
            <span className="grid">
              <span className={`text-[1rem] font-semibold ${s.state === "waiting" ? "text-ink-faint" : "text-ink"}`}>{s.label}</span>
              <span className="tabular text-[0.875rem] text-ink-muted">{s.detail}</span>
            </span>
          </li>
        ))}
      </ol>
    </div>
  );
}
