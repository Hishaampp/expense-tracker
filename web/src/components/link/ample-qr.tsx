import { encode } from "uqr";

/**
 * A QR code in Ample's hand: round data dots, soft finder squares, and the
 * mark in the middle (error correction H keeps it readable). Always ink on
 * a white plate, whatever the theme, so every phone camera reads it.
 */
export function AmpleQr({ text, size = 248, label }: { text: string; size?: number; label: string }) {
  const { data, size: n } = encode(text, { ecc: "H", border: 0 });
  const quiet = 3;
  const total = n + quiet * 2;
  const finders: [number, number][] = [
    [0, 0],
    [n - 7, 0],
    [0, n - 7],
  ];
  const inFinder = (x: number, y: number) =>
    finders.some(([fx, fy]) => x >= fx && x < fx + 7 && y >= fy && y < fy + 7);
  // A clear circle for the mark, about a fifth of the code.
  const c = n / 2;
  const hole = n * 0.15;
  const inHole = (x: number, y: number) => Math.hypot(x + 0.5 - c, y + 0.5 - c) < hole + 0.9;

  const dots: React.ReactNode[] = [];
  for (let y = 0; y < n; y++) {
    for (let x = 0; x < n; x++) {
      if (!data[y][x] || inFinder(x, y) || inHole(x, y)) continue;
      dots.push(<circle key={`${x}-${y}`} cx={x + quiet + 0.5} cy={y + quiet + 0.5} r={0.44} />);
    }
  }
  return (
    <svg viewBox={`0 0 ${total} ${total}`} width={size} height={size} role="img" aria-label={label} className="block rounded-[1.25rem] bg-white">
      <g fill="#121212">
        {dots}
        {finders.map(([fx, fy]) => (
          <g key={`${fx}-${fy}`} transform={`translate(${fx + quiet} ${fy + quiet})`}>
            <rect x={0.5} y={0.5} width={6} height={6} rx={1.9} fill="none" stroke="#121212" strokeWidth={1} />
            <rect x={2} y={2} width={3} height={3} rx={0.9} />
          </g>
        ))}
      </g>
      {/* The mark, centred: ring and bar in ink, honey in the bowl. */}
      <g transform={`translate(${c + quiet} ${c + quiet}) scale(${(hole * 1.7) / 66}) translate(-50 -50)`}>
        <circle cx="50" cy="50" r="28" fill="none" stroke="#121212" strokeWidth="10" />
        <rect x="73" y="17" width="10" height="66" rx="5" fill="#121212" />
        <clipPath id="qr-bowl">
          <circle cx="50" cy="50" r="19.5" />
        </clipPath>
        <rect x="20" y="40" width="60" height="40" fill="#F2B33D" clipPath="url(#qr-bowl)" />
      </g>
    </svg>
  );
}
