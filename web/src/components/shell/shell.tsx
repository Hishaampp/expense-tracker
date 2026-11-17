"use client";

import { LockKeyhole, LogOut, Menu, Moon, Sun, X } from "lucide-react";
import { motion } from "motion/react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { AmpleLockup } from "@/components/brand/ample-mark";
import { cloud } from "@/lib/cloud/client";
import { useSession } from "@/lib/session/session";
import { useTheme } from "@/lib/theme/theme";
import { IDLE_LOCK_MS, useVault } from "@/lib/vault/vault-context";
import { NAV } from "./nav";

function useMinutesLeft(lockAt: number) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const t = window.setInterval(() => setNow(Date.now()), 10_000);
    return () => window.clearInterval(t);
  }, []);
  return Math.min(IDLE_LOCK_MS / 60_000, Math.max(1, Math.ceil((lockAt - now) / 60_000)));
}

function NavList({ onNavigate }: { onNavigate?: () => void }) {
  const path = usePathname();
  return (
    <ul className="grid gap-0.5">
      {NAV.map(({ href, label, icon: Icon, ready }) => {
        const active = path === href;
        const body = (
          <>
            {active && (
              <motion.span
                layoutId="nav-active"
                className="absolute inset-0 rounded-xl bg-raised shadow-[var(--shadow-near)]"
                transition={{ type: "spring", stiffness: 420, damping: 36 }}
              />
            )}
            <Icon className={`relative size-[18px] ${active ? "text-honey-text" : ""}`} strokeWidth={1.85} aria-hidden />
            <span className="relative flex-1">{label}</span>
            {!ready && <span className="relative text-[0.6875rem] font-semibold text-ink-faint">Soon</span>}
          </>
        );
        const cls = `relative flex h-10 items-center gap-3 rounded-xl px-3 text-[0.9375rem] font-semibold transition-colors ${
          active ? "text-ink" : ready ? "text-ink-muted hover:text-ink" : "cursor-default text-ink-faint/80"
        }`;
        return (
          <li key={href}>
            {ready ? (
              <Link href={href} className={cls} aria-current={active ? "page" : undefined} onClick={onNavigate}>
                {body}
              </Link>
            ) : (
              <span className={cls} aria-disabled>
                {body}
              </span>
            )}
          </li>
        );
      })}
    </ul>
  );
}

function SidebarFooter() {
  const { state, lock } = useVault();
  const session = useSession();
  const { theme, toggle } = useTheme();
  const minutes = useMinutesLeft(state.status === "open" ? state.lockAt : 0);
  const email = session.status === "signed-in" ? session.session.user.email : null;
  return (
    <div className="grid gap-3">
      <div className="rounded-2xl border border-line bg-ground/60 p-4">
        <p className="flex items-center gap-2 text-[0.875rem] font-semibold">
          <span className="relative flex size-2">
            <span className="absolute inset-0 animate-ping rounded-full bg-income opacity-50" />
            <span className="relative size-2 rounded-full bg-income" />
          </span>
          Unlocked in this tab
        </p>
        <p className="tabular mt-1 text-[0.8125rem] text-ink-muted">Locks after {minutes} min without use</p>
        <button
          type="button"
          onClick={lock}
          className="mt-3 inline-flex h-9 w-full items-center justify-center gap-2 rounded-full border border-line-strong/60 text-[0.875rem] font-semibold transition-colors hover:border-honey hover:text-honey-text"
        >
          <LockKeyhole className="size-4" aria-hidden /> Lock now
        </button>
      </div>
      <div className="flex items-center gap-2 px-1">
        <span className="min-w-0 flex-1 truncate text-[0.8125rem] text-ink-muted" title={email ?? undefined}>
          {email}
        </span>
        <button
          type="button"
          onClick={toggle}
          aria-label={theme === "dark" ? "Switch to light" : "Switch to dark"}
          className="grid size-9 place-items-center rounded-full text-ink-muted transition-colors hover:bg-raised hover:text-ink"
        >
          {theme === "dark" ? <Sun className="size-[18px]" aria-hidden /> : <Moon className="size-[18px]" aria-hidden />}
        </button>
        <button
          type="button"
          onClick={() => {
            lock();
            void cloud().auth.signOut();
          }}
          aria-label="Sign out"
          className="grid size-9 place-items-center rounded-full text-ink-muted transition-colors hover:bg-raised hover:text-ink"
        >
          <LogOut className="size-[18px]" aria-hidden />
        </button>
      </div>
    </div>
  );
}

/** The dashboard frame: a side rail on desktop, a drawer on small screens. */
export function Shell({ children }: { children: React.ReactNode }) {
  const [drawer, setDrawer] = useState(false);
  return (
    <div className="min-h-dvh lg:grid lg:grid-cols-[17rem_minmax(0,1fr)]">
      <aside className="sticky top-0 hidden h-dvh flex-col justify-between border-r border-line bg-rail px-4 py-6 lg:flex">
        <div className="grid gap-8">
          <div className="px-2">
            <AmpleLockup />
          </div>
          <nav aria-label="Dashboard">
            <NavList />
          </nav>
        </div>
        <SidebarFooter />
      </aside>

      <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b border-line bg-ground/90 px-4 backdrop-blur lg:hidden">
        <AmpleLockup size={24} />
        <button type="button" aria-label="Open menu" onClick={() => setDrawer(true)} className="grid size-10 place-items-center rounded-full hover:bg-raised">
          <Menu className="size-5" aria-hidden />
        </button>
      </header>
      {drawer && (
        <div className="fixed inset-0 z-30 lg:hidden" role="dialog" aria-modal aria-label="Menu">
          <button type="button" aria-label="Close menu" className="absolute inset-0 bg-black/50" onClick={() => setDrawer(false)} />
          <div className="absolute inset-y-0 left-0 flex w-[min(19rem,86vw)] flex-col justify-between bg-rail px-4 py-6">
            <div className="grid gap-8">
              <div className="flex items-center justify-between px-2">
                <AmpleLockup size={24} />
                <button type="button" aria-label="Close menu" onClick={() => setDrawer(false)} className="grid size-9 place-items-center rounded-full hover:bg-raised">
                  <X className="size-5" aria-hidden />
                </button>
              </div>
              <nav aria-label="Dashboard">
                <NavList onNavigate={() => setDrawer(false)} />
              </nav>
            </div>
            <SidebarFooter />
          </div>
        </div>
      )}

      <main className="min-w-0 px-5 py-8 sm:px-8 lg:px-12 lg:py-10">{children}</main>
    </div>
  );
}
