import { LockKeyhole, MonitorSmartphone, ShieldCheck } from "lucide-react";
import { AmpleLockup } from "@/components/brand/ample-mark";

const FACTS = [
  { icon: ShieldCheck, text: "Sealed with AES-256 on your phone. The server holds only locked records." },
  { icon: LockKeyhole, text: "Unlocked inside this tab, and forgotten when you lock or close it." },
  { icon: MonitorSmartphone, text: "The same records as your phone, to the paisa." },
];

/**
 * The sign-in and unlock frame: the brand side holds the mark (whatever
 * [art] says it is doing), the work side holds the task.
 */
export function SplitFrame({ art, children }: { art: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="grid min-h-dvh lg:grid-cols-[minmax(0,1.08fr)_minmax(0,1fr)]">
      <aside className="relative hidden overflow-hidden border-r border-line bg-rail lg:flex lg:flex-col">
        <div className="px-12 pt-10">
          <AmpleLockup />
        </div>
        <div className="flex flex-1 items-center justify-center">{art}</div>
        <ul className="grid gap-4 px-12 pb-12">
          {FACTS.map(({ icon: Icon, text }, i) => (
            <li key={text} className="rise flex max-w-[30rem] items-start gap-3.5 text-[0.9375rem] leading-relaxed text-ink-muted" style={{ "--i": i + 4 } as React.CSSProperties}>
              <Icon className="mt-0.5 size-[18px] shrink-0 text-honey-text" strokeWidth={1.75} aria-hidden />
              <span>{text}</span>
            </li>
          ))}
        </ul>
      </aside>
      <main className="flex flex-col px-6 py-8 sm:px-12 lg:px-16">
        <div className="lg:hidden">
          <AmpleLockup size={26} />
        </div>
        <div className="flex flex-1 items-center">
          <div className="w-full max-w-[27rem] py-12">{children}</div>
        </div>
        <p className="text-[0.8125rem] text-ink-faint">Free for every Ample user.</p>
      </main>
    </div>
  );
}
