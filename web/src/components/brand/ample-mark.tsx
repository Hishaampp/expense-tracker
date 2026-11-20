/**
 * The Ample mark: an "a" whose bowl holds honey (honey means "what you have").
 * Geometry from tool/render_brand_mark.py, viewBox 17..83. [level] is how
 * full the bowl is, 0 to 1; 1 is the logo's own level.
 */
export function AmpleMark({
  level = 1,
  size = 40,
  sway = false,
  className,
  title = "Ample",
  honeyOpacity = 1,
}: {
  level?: number;
  size?: number;
  sway?: boolean;
  className?: string;
  title?: string | null;
  /** Below 1 for a watermark, so the honey stays as quiet as the ring. */
  honeyOpacity?: number;
}) {
  // Full honey sits at y=40 (the logo); empty is the bowl's bottom, 69.5.
  const surface = 69.5 - Math.max(0, Math.min(1, level)) * 29.5;
  const id = `bowl-${size}-${sway ? "s" : "f"}`;
  return (
    <svg
      viewBox="17 17 66 66"
      width={size}
      height={size}
      className={className}
      role={title ? "img" : undefined}
      aria-hidden={title ? undefined : true}
      aria-label={title ?? undefined}
    >
      <defs>
        <clipPath id={id}>
          <circle cx="50" cy="50" r="19.5" />
        </clipPath>
      </defs>
      <g clipPath={`url(#${id})`}>
        <g
          style={{
            transform: `translateY(${surface - 40}px)`,
            transition: "transform 700ms var(--ease-out-expo)",
          }}
        >
          <path
            d="M10 40 q 7.5 -2.2 15 0 t 15 0 t 15 0 t 15 0 t 15 0 t 15 0 V 90 H 10 Z"
            fill="var(--honey)"
            fillOpacity={honeyOpacity}
            style={
              sway
                ? { animation: "honey-sway 3.6s var(--ease-honey) infinite" }
                : undefined
            }
          />
        </g>
      </g>
      <circle cx="50" cy="50" r="28" fill="none" stroke="currentColor" strokeWidth="10" />
      <rect x="73" y="17" width="10" height="66" rx="5" fill="currentColor" />
    </svg>
  );
}

/** The mark beside the name, for the sidebar and headers. */
export function AmpleLockup({ size = 28 }: { size?: number }) {
  return (
    <span className="inline-flex items-center gap-2.5 text-ink">
      <AmpleMark size={size} title={null} />
      <span className="font-display text-[1.35rem] leading-none tracking-[-0.01em]">Ample</span>
    </span>
  );
}
