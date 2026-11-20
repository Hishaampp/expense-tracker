# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Next.js (static export, no server code), TypeScript, hosted on Vercel at
https://ample-money.vercel.app. Chosen in `docs/WEB_DASHBOARD_PLAN.md`.

## Users

People who already use the Ample phone app (Android and iPhone, India, ₹)
and have turned on Account & sync. They open the website on a computer to
sit down with their money: review a month, search for payments, and export
records.

## Product Purpose

Ample for the web shows everything the phone has recorded (payments,
money in, categories, payees, Rooms and trips, budgets) as a financial
dashboard, and exports it to Excel, CSV and a PDF statement. Success: the
numbers match the phone to the paisa, and someone can understand their month
or produce a file for their records within a minute of unlocking.

## Positioning

End-to-end encrypted: the server stores only sealed records it cannot read.
The website unlocks them inside the browser tab with the sync key, handed
over from the phone by QR or typed as the recovery code. "Even we can't read
your finances" is true, and the design may say so.

## Operating Context

- Desktop first (laptop or monitor, a deliberate sitting), usable on tablet
  and phone.
- Sign-in through the same Supabase account as the app (Google or email
  link), then an unlock step every session; the key lives only in memory
  and locks after 15 minutes idle or on closing the tab.
- v1 is read-only plus exports; editing comes later.

## Capabilities and Constraints

- Free for every Ample user at launch. A paid tier may come later and is
  undecided; nothing in v1 is gated or labelled as paid.
- Money is integer paise; the month may start on a custom day; refunds
  reduce their payment's category and Room; transfers and hidden payments
  are not spending.
- Strict privacy: the page talks only to the Supabase project; no
  analytics, no third-party scripts or fonts at runtime; unlocked data never
  touches storage or the URL.

## Brand Commitments

- Name **Ample**; the mark is an "a" whose bowl holds honey (honey means
  "what you have"). Geometry in `tool/render_brand_mark.py`.
- Colours, type (Fraunces for display and key amounts, Manrope for UI) and
  money rules from `docs/DESIGN.md`: spending is ink, never red; money in
  is green and always carries "+" or words.
- Dark by default, light available, matching the app.
- The owner asked for a premium look: polished and richly animated,
  including Lottie-style brand animations. "Premium" describes the feel,
  not a paid plan.

## Evidence on Hand

- Brand assets: `assets/brand/`, fonts in `assets/fonts/` (OFL).
- No testimonials, user counts, press or ratings exist; none may be shown.

## Product Principles

1. The numbers are exact and match the phone; never estimate or round away
   paise in totals.
2. Privacy is visible: say plainly what is unlocked, where, and for how long.
3. Calm, then deep: the month at a glance first, every detail one step away.
4. Motion explains state (unlocking, loading, changing period); it never
   delays a task and stops under reduced motion.

## Accessibility & Inclusion

WCAG 2.2 AA: contrast, full keyboard use, visible focus, screen-reader
labels for charts (with a table equivalent), reduced motion honoured.
