"use client";

import { animate, useReducedMotion } from "motion/react";
import { useEffect, useRef } from "react";

/** A number that counts up once when it appears; the final text is in the HTML. */
export function CountUp({ value, format }: { value: number; format: (n: number) => string }) {
  const ref = useRef<HTMLSpanElement>(null);
  const reduce = useReducedMotion();
  useEffect(() => {
    const el = ref.current;
    if (!el || reduce) return;
    const controls = animate(0, value, {
      duration: 1.1,
      ease: [0.16, 1, 0.3, 1],
      onUpdate: (n) => {
        el.textContent = format(Math.round(n));
      },
    });
    return () => controls.stop();
  }, [value, format, reduce]);
  return (
    <span ref={ref} className="tabular">
      {format(value)}
    </span>
  );
}
