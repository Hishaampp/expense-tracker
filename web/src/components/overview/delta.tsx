import { ArrowDownRight, ArrowUpRight, Equal } from "lucide-react";
import { formatPaise } from "@/lib/format/format";

/**
 * "₹2,300 less than October": the change in words and an arrow, never
 * colour alone. [goodWhenLower] colours a fall as good (spending) or a
 * rise as good (money in).
 */
export function Delta({
  now,
  before,
  versus,
  goodWhenLower,
  tone = "card",
}: {
  now: number;
  before: number;
  versus: string;
  goodWhenLower: boolean;
  tone?: "card" | "hero";
}) {
  const diff = now - before;
  const muted = tone === "hero" ? "text-on-hero-muted" : "text-ink-muted";
  if (before === 0 && now === 0) return <p className={`text-[0.8125rem] ${muted}`}>Nothing in {versus} either</p>;
  if (diff === 0)
    return (
      <p className={`inline-flex items-center gap-1 text-[0.8125rem] ${muted}`}>
        <Equal className="size-3.5" aria-hidden /> Same as {versus}
      </p>
    );
  const good = goodWhenLower ? diff < 0 : diff > 0;
  const Icon = diff > 0 ? ArrowUpRight : ArrowDownRight;
  return (
    <p className={`tabular inline-flex items-center gap-1 text-[0.8125rem] ${muted}`}>
      <span className={`inline-flex items-center gap-0.5 font-semibold ${good ? (tone === "hero" ? "text-hero-good" : "text-income") : tone === "hero" ? "text-honey" : "text-honey-text"}`}>
        <Icon className="size-3.5" aria-hidden />
        {formatPaise(Math.abs(diff))}
      </span>
      {diff > 0 ? "more" : "less"} than {versus}
    </p>
  );
}
