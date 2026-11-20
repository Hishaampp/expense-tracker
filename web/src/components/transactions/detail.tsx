"use client";

import { ArrowRight, X } from "lucide-react";
import { useEffect, useRef } from "react";
import { categoryStyle } from "@/components/overview/category-style";
import { formatFullWhen, formatPaise } from "@/lib/format/format";
import type { Item } from "@/lib/insights/tables";
import { Amount, KIND_LABEL, ORIGIN_LABEL } from "./amount";
import { titleOf } from "./table";

const INSTRUMENT: Record<string, string> = { upi: "UPI", card: "Card", netbanking: "Net banking", imps: "IMPS", neft: "NEFT", rtgs: "RTGS", atm: "ATM", wallet: "Wallet", cash: "Cash" };

/**
 * One transaction in full, in a panel beside the table. A refund shows the
 * payment it gives back (and a payment its refunds); a transfer shows both
 * accounts. Esc or the close button closes it.
 */
export function TransactionDetail({ item, linked, onClose, onOpen }: { item: Item; linked: Item[]; onClose: () => void; onOpen: (id: string) => void }) {
  const close = useRef<HTMLButtonElement>(null);
  useEffect(() => close.current?.focus(), [item.t.id]);
  const t = item.t;
  const { Icon, color } = categoryStyle(item.category?.icon ?? (t.kind === "transfer" ? "transfer" : t.kind === "income" ? "income" : null));
  const facts: [string, React.ReactNode][] = [
    ["When", formatFullWhen(t.at)],
    ["Kind", KIND_LABEL[t.kind]],
    t.kind === "transfer"
      ? ["Accounts", <span key="a" className="inline-flex items-center gap-1.5">{item.account?.name ?? "—"} <ArrowRight className="size-3.5 text-ink-muted" aria-label="to" /> {item.toAccount?.name ?? "—"}</span>]
      : ["Account", item.account?.name ?? "—"],
    ["Category", item.category?.name ?? "Uncategorised"],
    ["Room", item.room ? `${item.room.emoji ?? ""} ${item.room.name}`.trim() : "—"],
    ["Recorded", `${ORIGIN_LABEL[t.origin] ?? t.origin}${t.needsReview ? ", waiting for a category" : ""}`],
    ["Paid by", t.instrument && INSTRUMENT[t.instrument] ? INSTRUMENT[t.instrument] : "—"],
  ];
  if (t.payeeKey && t.payeeKey !== t.payeeDisplay) facts.push(["UPI id or payee", t.payeeKey]);
  if (t.refNo) facts.push(["Reference", <span key="r" className="tabular font-mono text-[0.8125rem]">{t.refNo}</span>]);

  return (
    <aside aria-label="Transaction details" className="fixed inset-y-0 right-0 z-40 flex w-[min(28rem,100vw)] flex-col border-l border-line bg-ground shadow-[var(--shadow-far)]" onKeyDown={(e) => e.key === "Escape" && onClose()}>
      <div className="flex items-center justify-between px-6 pt-6">
        <p className="text-[0.875rem] font-semibold text-ink-muted">Details</p>
        <button ref={close} type="button" onClick={onClose} aria-label="Close details" className="grid size-9 place-items-center rounded-full text-ink-muted hover:bg-raised hover:text-ink">
          <X className="size-5" aria-hidden />
        </button>
      </div>
      <div className="grid gap-7 overflow-y-auto px-6 pt-4 pb-10">
        <div className="grid justify-items-start gap-3">
          <span className="grid size-12 place-items-center rounded-2xl text-on-tile" style={{ background: color }}>
            <Icon className="size-[22px]" strokeWidth={2} aria-hidden />
          </span>
          <h2 className="font-display text-[1.75rem] leading-tight">{titleOf(item)}</h2>
          <Amount kind={t.kind} paise={t.paise} className="font-display text-[2.25rem]" />
          {t.hidden && <p className="rounded-full bg-sunken px-3 py-1 text-[0.8125rem] text-ink-muted">Hidden on the phone: left out of every total</p>}
        </div>
        {t.note && <p className="rounded-xl bg-raised px-4 py-3 text-[0.9375rem]">{t.note}</p>}
        <dl className="grid gap-0 divide-y divide-line rounded-[1.25rem] border border-line bg-raised">
          {facts.map(([k, v]) => (
            <div key={k} className="grid grid-cols-[7.5rem_minmax(0,1fr)] gap-3 px-4 py-3 text-[0.9375rem]">
              <dt className="text-ink-muted">{k}</dt>
              <dd className="min-w-0 break-words">{v}</dd>
            </div>
          ))}
        </dl>
        {linked.length > 0 && (
          <div className="grid gap-2">
            <h3 className="text-[0.875rem] font-semibold text-ink-muted">{t.kind === "refund" ? "Refund of" : "Refunded by"}</h3>
            {linked.map((l) => (
              <button key={l.t.id} type="button" onClick={() => onOpen(l.t.id)} className="flex items-center justify-between gap-3 rounded-xl border border-line bg-raised px-4 py-3 text-left transition-colors hover:bg-raised-2">
                <span className="min-w-0">
                  <span className="block truncate font-semibold">{titleOf(l)}</span>
                  <span className="block text-[0.8125rem] text-ink-muted">{formatFullWhen(l.t.at)}</span>
                </span>
                <span className="tabular shrink-0 font-semibold">{formatPaise(l.t.paise)}</span>
              </button>
            ))}
          </div>
        )}
      </div>
    </aside>
  );
}
