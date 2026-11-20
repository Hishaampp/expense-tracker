/** A titled block of a dashboard page. */
export function Card({ id, title, note, action, children, i = 0, className = "" }: { id: string; title: string; note?: React.ReactNode; action?: React.ReactNode; children: React.ReactNode; i?: number; className?: string }) {
  return (
    <section aria-labelledby={id} className={`rise grid content-start gap-5 rounded-[1.25rem] border border-line bg-raised p-5 sm:p-7 ${className}`} style={{ "--i": i } as React.CSSProperties}>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="grid gap-1">
          <h2 id={id} className="font-display text-[1.5rem] tracking-[-0.01em]">
            {title}
          </h2>
          {note && <p className="text-[0.875rem] text-ink-muted">{note}</p>}
        </div>
        {action}
      </div>
      {children}
    </section>
  );
}

/** What a block shows when there is nothing in it. */
export function Quiet({ children }: { children: React.ReactNode }) {
  return <p className="rounded-xl bg-sunken px-4 py-6 text-center text-[0.9375rem] text-ink-muted">{children}</p>;
}
