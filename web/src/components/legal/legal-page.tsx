import Link from "next/link";
import { AmpleLockup } from "@/components/brand/ample-mark";

/** Who runs Ample and how to reach them, shown on the legal pages. */
export const DEVELOPER = "Hisham P P";
export const CONTACT_EMAIL = "hishampp198@gmail.com";

/**
 * A public document page (privacy policy, terms): readable without signing
 * in, rendered to plain HTML so anyone, including store reviewers, can
 * read it.
 */
export function LegalPage({ title, updated, intro, children }: { title: string; updated: string; intro: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="min-h-dvh bg-ground text-ink">
      <header className="border-b border-line">
        <div className="mx-auto flex max-w-[46rem] items-center justify-between px-5 py-5">
          <Link href="/" aria-label="Ample home">
            <AmpleLockup size={26} />
          </Link>
          <nav aria-label="Legal" className="flex gap-5 text-[0.875rem] font-semibold text-ink-muted">
            <Link href="/privacy" className="hover:text-ink">
              Privacy
            </Link>
            <Link href="/terms" className="hover:text-ink">
              Terms
            </Link>
          </nav>
        </div>
      </header>
      <main className="mx-auto max-w-[46rem] px-5 pt-12 pb-20">
        <h1 className="font-display text-[2.4rem] leading-[1.08] tracking-[-0.02em] sm:text-[2.9rem]">{title}</h1>
        <p className="mt-3 text-[0.9375rem] text-ink-muted">Last updated: {updated}</p>
        <div className="mt-8 rounded-[1.25rem] border border-line bg-raised p-5 text-[1.0625rem] leading-relaxed sm:p-6">{intro}</div>
        <article className="legal mt-10">{children}</article>
        <footer className="mt-14 border-t border-line pt-6 text-[0.9375rem] text-ink-muted">
          {DEVELOPER} ·{" "}
          <a href={`mailto:${CONTACT_EMAIL}`} className="font-semibold text-honey-text hover:underline">
            {CONTACT_EMAIL}
          </a>
        </footer>
      </main>
    </div>
  );
}
