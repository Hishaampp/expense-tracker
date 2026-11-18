import { formatCount, formatPaise } from "@/lib/format/format";
import type { PayeeLine } from "@/lib/insights/overview";

/** Where the money went most: total, how many payments, and the usual size. */
export function TopPayees({ lines }: { lines: PayeeLine[] }) {
  const top = lines[0]?.spent ?? 0;
  return (
    <ol className="grid gap-1">
      {lines.map((p, i) => (
        <li key={p.key} className="grid grid-cols-[1.75rem_minmax(0,1fr)_auto] items-center gap-x-3 rounded-xl px-2 py-2.5 transition-colors hover:bg-raised-2">
          <span className="tabular grid size-7 place-items-center rounded-full bg-honey-soft text-[0.75rem] font-bold text-honey-text">{i + 1}</span>
          <div className="min-w-0">
            <p className="truncate text-[0.9375rem] font-semibold">{p.name}</p>
            <p className="tabular text-[0.8125rem] text-ink-muted">
              {formatCount(p.payments)} {p.payments === 1 ? "payment" : "payments"} · {formatPaise(p.average)} each
            </p>
            <div className="mt-1.5 h-1 overflow-hidden rounded-full bg-sunken" aria-hidden>
              <div className="grow-x h-full origin-left rounded-full bg-honey/70" style={{ transform: `scaleX(${top ? p.spent / top : 0})` }} />
            </div>
          </div>
          <p className="tabular text-[0.9375rem] font-semibold">{formatPaise(p.spent)}</p>
        </li>
      ))}
    </ol>
  );
}
