/** A dashboard page's title, its muted line, and anything on the right (a search, a picker). */
export function PageHeader({ title, note, children }: { title: string; note?: React.ReactNode; children?: React.ReactNode }) {
  return (
    <header className="flex flex-wrap items-end justify-between gap-x-6 gap-y-4">
      <div className="grid gap-2">
        <h1 className="rise font-display text-[2.4rem] leading-[1.05] tracking-[-0.02em] sm:text-[3rem]">{title}</h1>
        {note && (
          <p className="rise text-[1.0625rem] text-ink-muted" style={{ "--i": 1 } as React.CSSProperties}>
            {note}
          </p>
        )}
      </div>
      {children && (
        <div className="rise w-full sm:w-auto" style={{ "--i": 1 } as React.CSSProperties}>
          {children}
        </div>
      )}
    </header>
  );
}
