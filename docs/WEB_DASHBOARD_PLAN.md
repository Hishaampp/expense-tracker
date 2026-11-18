# Ample for the web: dashboard plan

The goal: sign in on a computer and see **all your Ample records** in an attractive financial dashboard, with exports to **Excel, CSV and PDF**, while keeping the promise the app already makes: **the server can never read your money.**

v1 is **read-only plus exports**. Editing from the web comes in v2.

## The one design constraint

Your phone syncs to Supabase, but only as **sealed records** (AES-256-GCM; the record ids are HMACs, so even table names are hidden). Signing in with Google gives the website the sealed records, **not** the data. The website must unlock them **in the browser** with the sync key, exactly as a second phone does.

So the website:

- downloads the sealed records (the same `sync_records` table and row-level security the app uses);
- gets the sync key from your phone (QR) or your recovery code;
- unlocks and reads everything **in the tab's memory**. Nothing readable is sent anywhere, stored on the server, or written to disk.

## How you get in

1. **Sign in** with Google or an email link (the same Supabase account as the app).
2. **Unlock**, one of:
   - **Scan with your phone (recommended):** the website shows a QR code. In Ample: **Settings → Account & sync → Link a computer**, scan it, check the computer's name and confirm. The website unlocks within a second or two. No code is typed.
   - **Recovery code:** type it in. For when the phone is not at hand.
3. **Lock:** after 15 minutes without use, on closing the tab, or with **Lock** in the menu. Reloading the page asks to unlock again (the key lives only in memory).

### How the QR handover stays private

1. The website makes a one-time key pair (X25519) and shows a QR with a pairing id and its public key.
2. The phone, signed in to the **same account**, scans it, asks you to confirm, and seals the sync key for that one-time public key (X25519 + HKDF + AES-GCM).
3. It stores that sealed key in a new `pairing_requests` row. Row-level security lets only your own account read or write it, and it expires after 2 minutes.
4. The website reads the row, unseals the key with its one-time private key and deletes the row.

The server only ever relays a sealed key it cannot open. A stranger who photographs the QR gets nothing: they would need your account to post to it, and you confirm on the phone.

## What you see

**Look and feel:** the Ample brand from `docs/DESIGN.md` (cream and honey, the same type, the same money colours), **dark by default** like the app, with light available. Desktop-first, and still usable on a tablet or phone.

**Layout:** a side menu (Overview · Transactions · Categories · Payees · Rooms · Budgets · Export), a period picker at the top that respects your month start day, and Lock and account in the corner.

### Overview
- Key numbers for the period: **spent**, **money in**, **net**, **daily average**, and **safe to spend** where a budget is set, each against the previous period.
- **12-month trend:** spending and income, month by month.
- **Category breakdown:** a donut and a ranked list, each against its budget.
- **Top payees:** total, number of payments and average, for example "Swiggy · ₹4,200 · 23 orders".
- **Calendar heatmap** of daily spending.
- **Needs review:** a count of captured payments still waiting for a category.

### Transactions
- A fast table (thousands of rows, scrolled smoothly) with date, payee, category, account, Room, amount, how it was recorded (auto-captured, scanned or manual) and note.
- **Search** and **filters** (date range, category, account, Room, kind, needs review), with **totals for what is filtered**.
- Sort by any column, and keyboard shortcuts (`/` search, `j`/`k` move, `Esc` clear).
- Click a row for its details: a refund shows the payment it refunds, and a transfer shows both accounts.

### Categories and Payees
Each category or payee with its month-by-month history and its own transactions.

### Rooms
Each trip or Room with its total, a day-by-day chart, its categories and its transactions.

### Budgets
Each budget's month, how much is left, and the last 6 months against the budget.

### Export
For any date range and the current filters:

- **Excel (.xlsx):** sheets for Summary, Transactions, Categories, Payees and Rooms. Amounts are real numbers formatted as ₹, totals are live formulas, the header row is frozen and filters are on.
- **CSV:** the transactions, for Google Sheets or any other tool.
- **PDF statement:** a branded monthly statement with the key numbers, the category breakdown and every transaction. Good as an expense report.

Exports are built **in the browser**, so your data still never reaches a server.

## The numbers must match the phone

Totals on the web must equal the app's, to the paisa. The web follows the app's rules exactly:

- money is integer **paise** (`amountPaise`), never decimals;
- the custom **month start day**;
- **refunds** reduce their original payment's category and Room;
- **transfers** and hidden payments are not spending;
- money in, budgets and safe-to-spend are calculated as on Home.

To prove it, a Dart tool generates **shared test cases** from the app's own code: sealed records made with a fixed test key, and the expected totals for a sample month. The website's tests must unlock those records and reach the same totals. If the app's rules change, these cases change, and the web's tests fail until it catches up.

## How it's built

- **Where:** a new `web/` folder in this repo, with its own CI job.
- **Stack:** Next.js (static export, so there is no server code), TypeScript, Tailwind with the Ample tokens, TanStack Table for the table, Recharts for the charts, ExcelJS for Excel, and a PDF library for the statement.
- **Crypto:** the browser's built-in WebCrypto for AES-GCM, HMAC, HKDF and X25519.
- **Hosting:** Vercel, free, at a `….vercel.app` address to start; your own domain can be added later.
- **Security:**
  - a strict Content Security Policy: the page may talk **only** to the Supabase project, and loads no third-party scripts, analytics or fonts from elsewhere;
  - no cookies besides Supabase's sign-in session;
  - unlocked data never goes to `localStorage`, IndexedDB or the URL.
- **Unknown or newer data:** if the phone runs a newer app with extra fields, the web ignores them and still shows what it knows; a record it cannot read is counted and noted, never guessed.

### Changes to the phone app
- **Settings → Account & sync → Link a computer:** a scanner (the app already has one for Scan & Record), a confirm sheet showing the computer's name, and "Linked" when done.
- One new Supabase migration: the `pairing_requests` table with row-level security and a 2-minute expiry.
- The Dart tool that writes the shared test cases.

## Build steps

| Step | What | Done when |
|---|---|---|
| **W1** | `web/` set up with CI; crypto ported; shared test cases from Dart; sign in; unlock with the recovery code; load and unlock all records | Web tests unlock the Dart test cases; your real data loads after typing your code |
| **W2** | QR unlock: migration, the phone's **Link a computer** screen, the website's QR screen | Scanning on the phone unlocks the website |
| **W3** | Layout, brand and the **Overview** | Overview totals match the app's Home for the same month |
| **W4** | **Transactions**, Categories, Payees, Rooms and Budgets | Filters and totals match the app |
| **W5** | **Export**: Excel, CSV and the PDF statement | Exported totals match the screen; the file opens cleanly in Excel and Google Sheets |
| **W6** | Deploy to Vercel; auto-lock; security headers; final check | Live at its address and checked on a real account |
| v2 | Editing from the web (re-categorise in bulk, fix payees, notes), sealed and synced back to the phones | Later |

Each step is its own commit, tested, with CI passing; the whole web dashboard is one PR.

## What I need from you (I'll guide each one when we get there)

1. **Vercel account** (free; sign in with GitHub), at W6.
2. **Supabase:** run the new migration (W2), and add the website's address under **Authentication → URL Configuration → Redirect URLs** (W1 for local testing, W6 for the live address).
3. **Google Cloud:** add the website's address to the sign-in client's **Authorized JavaScript origins** (W1 and W6).
4. **Your recovery code**, or the phone at hand, to test with your real data.

## Remember this computer (added after W4)

Scanning on every visit was too much, so the unlock screen offers **Keep this computer unlocked for 30 days** (on by default, with a note to leave it off on a shared computer). The sync key is sealed with AES-256-GCM under a **non-extractable** wrapping key in IndexedDB, tied to the account; it opens the dashboard on the next visit without a scan. Lock and the idle lock still lock the tab (one click reopens), and **Forget this computer** or signing out removes it. A key that no longer opens the records (sync started over) is removed automatically.

## Not in v1

- Editing, adding or deleting from the web (v2).
- Auto-capture on the web (it only exists on the phone).
- Sharing a dashboard with someone else.
