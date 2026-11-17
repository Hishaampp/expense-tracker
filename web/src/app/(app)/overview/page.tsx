"use client";

import { ArrowDownLeft, CalendarRange, Inbox, Landmark, Plane, Shapes, Wallet } from "lucide-react";
import { useMemo } from "react";
import { AmpleMark } from "@/components/brand/ample-mark";
import { CountUp } from "@/components/ui/count-up";
import { inventory } from "@/lib/insights/inventory";
import { formatCount, formatMonth, formatWhen } from "@/lib/format/format";
import { useVault } from "@/lib/vault/vault-context";

function greeting(hour: number) {
  return hour < 5 ? "Good evening." : hour < 12 ? "Good morning." : hour < 17 ? "Good afternoon." : "Good evening.";
}

export default function OverviewPage() {
  const { state } = useVault();
  const vault = state.status === "open" ? state.vault : null;
  const inv = useMemo(() => (vault ? inventory(vault) : null), [vault]);
  if (!vault || !inv) return null;

  const since = inv.firstAt ? formatMonth(inv.firstAt) : null;
  const rows = [
    { icon: Wallet, label: "Payments", value: inv.payments, note: inv.refunds ? `${formatCount(inv.refunds)} refunds linked` : "Spending you recorded or Ample captured" },
    { icon: ArrowDownLeft, label: "Money in", value: inv.moneyIn, note: "Salary, refunds received and other income" },
    { icon: Landmark, label: "Accounts", value: inv.accounts, note: inv.transfers ? `${formatCount(inv.transfers)} transfers between them` : "Banks, cards, wallets and cash" },
    { icon: Shapes, label: "Categories", value: inv.categories, note: `${formatCount(inv.budgets)} with a budget` },
    { icon: Plane, label: "Rooms and trips", value: inv.rooms, note: "Spending kept together" },
  ];

  return (
    <div className="mx-auto grid max-w-[68rem] gap-10">
      <header className="grid gap-3">
        <h1 className="rise font-display text-[2.4rem] leading-[1.05] tracking-[-0.02em] sm:text-[3rem]">{greeting(new Date().getHours())}</h1>
        <p className="rise text-[1.0625rem] text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
          Everything from your phone, unlocked in this tab.
        </p>
      </header>

      <section
        aria-label="Your records"
        className="rise relative overflow-hidden rounded-[1.75rem] bg-hero p-8 text-on-hero shadow-[var(--shadow-far)] sm:p-10"
        style={{ "--i": 2 } as React.CSSProperties}
      >
        <AmpleMark size={300} sway title={null} honeyOpacity={0.14} className="pointer-events-none absolute -right-16 -bottom-20 text-on-hero/[0.07]" />
        <p className="relative max-w-[34rem] font-display text-[1.9rem] leading-[1.15] tracking-[-0.015em] text-balance sm:text-[2.35rem]">
          Your records are here: <span className="text-honey">
            <CountUp value={inv.payments + inv.moneyIn} format={formatCount} /> {inv.payments + inv.moneyIn === 1 ? "entry" : "entries"}
          </span>
          {since ? <> since {since}.</> : "."}
        </p>
        <div className="relative mt-8 flex flex-wrap gap-x-8 gap-y-3 text-[0.9375rem] text-on-hero-muted">
          {vault.lastChangedAt && (
            <span className="inline-flex items-center gap-2">
              <CalendarRange className="size-4 text-honey" aria-hidden /> Last change from your phone: {formatWhen(vault.lastChangedAt)}
            </span>
          )}
          {inv.needsReview > 0 && (
            <span className="inline-flex items-center gap-2">
              <Inbox className="size-4 text-honey" aria-hidden /> {formatCount(inv.needsReview)} waiting for a category on your phone
            </span>
          )}
        </div>
      </section>

      <section aria-labelledby="came-across" className="grid gap-5">
        <h2 id="came-across" className="rise font-display text-[1.5rem] tracking-[-0.01em]" style={{ "--i": 3 } as React.CSSProperties}>
          What came across
        </h2>
        <dl className="rise divide-y divide-line overflow-hidden rounded-[1.25rem] border border-line bg-raised" style={{ "--i": 4 } as React.CSSProperties}>
          {rows.map(({ icon: Icon, label, value, note }) => (
            <div key={label} className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-x-4 px-5 py-4 transition-colors hover:bg-raised-2 sm:px-6">
              <span className="grid size-10 place-items-center rounded-xl bg-honey-soft text-honey-text">
                <Icon className="size-[18px]" strokeWidth={1.85} aria-hidden />
              </span>
              <div className="min-w-0">
                <dt className="text-[1rem] font-semibold">{label}</dt>
                <p className="truncate text-[0.875rem] text-ink-muted">{note}</p>
              </div>
              <dd className="font-display text-[1.5rem]">
                <CountUp value={value} format={formatCount} />
              </dd>
            </div>
          ))}
        </dl>
        {vault.unreadable > 0 && (
          <p className="rounded-xl bg-honey-soft px-4 py-3 text-[0.9375rem] text-ink">
            {formatCount(vault.unreadable)} records couldn&apos;t be opened with this code, so they&apos;re left out. They may come from an older sync key.
          </p>
        )}
        <p className="text-[0.9375rem] text-ink-muted">
          Month totals, trends, categories and exports arrive here in the next updates.
        </p>
      </section>
    </div>
  );
}
