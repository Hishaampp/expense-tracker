"use client";

import { useEffect, useRef } from "react";
import { useTheme } from "@/lib/theme/theme";
import { AmpleMark } from "./ample-mark";

/**
 * The brand animation (tool/render_brand_lottie.py): three coins drop into
 * the bowl and the honey rises, then it keeps a slow sway. Reduced motion
 * shows the still mark instead.
 */
export function AmplePour({ size = 280, className }: { size?: number; className?: string }) {
  const host = useRef<HTMLDivElement>(null);
  const still = useRef<HTMLDivElement>(null);
  const { theme } = useTheme();

  useEffect(() => {
    const el = host.current;
    const fallback = still.current;
    if (!el || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    let disposed = false;
    let cleanup = () => {};
    (async () => {
      const lottie = (await import("lottie-web/build/player/lottie_light")).default;
      if (disposed) return;
      // Each animation gets its own layer: lottie empties its container
      // when destroyed, which would wipe the next one.
      const layer = () => {
        const div = document.createElement("div");
        div.className = "absolute inset-0 [&>svg]:!h-full [&>svg]:!w-full";
        el.appendChild(div);
        return div;
      };
      const pourLayer = layer();
      const pour = lottie.loadAnimation({
        container: pourLayer,
        renderer: "svg",
        autoplay: true,
        loop: false,
        path: `/brand/ample-pour-${theme}.json`,
      });
      let sway: ReturnType<typeof lottie.loadAnimation> | null = null;
      pour.addEventListener("DOMLoaded", () => {
        if (fallback) fallback.style.opacity = "0";
      });
      pour.addEventListener("complete", () => {
        if (disposed) return;
        sway = lottie.loadAnimation({
          container: layer(),
          renderer: "svg",
          autoplay: true,
          loop: true,
          path: `/brand/ample-sway-${theme}.json`,
        });
        sway.addEventListener("DOMLoaded", () => {
          pour.destroy();
          pourLayer.remove();
        });
      });
      cleanup = () => {
        pour.destroy();
        sway?.destroy();
        el.replaceChildren();
      };
    })();
    return () => {
      disposed = true;
      cleanup();
      if (fallback) fallback.style.opacity = "1";
    };
  }, [theme]);

  return (
    <div className={`relative text-ink ${className ?? ""}`} style={{ width: size, height: size }} aria-hidden>
      <div ref={still} className="absolute inset-[17.5%] transition-opacity duration-300">
        <AmpleMark size={size * 0.65} title={null} level={1} />
      </div>
      <div ref={host} className="absolute inset-0" />
    </div>
  );
}
