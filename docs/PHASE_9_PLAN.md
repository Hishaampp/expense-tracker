# Phase 9: Accounts & encrypted sync (plan)

The goal: an optional login, so your data follows you to a new phone and stays the same on two phones, **without the server being able to read it**. Without an account the app works exactly as v1 does.

## What changes in the spec

| v1 rule (spec §2, §13) | Phase 9 |
|---|---|
| No backend server | One hosted backend, **Supabase**: Postgres + Auth, Mumbai region, free tier to start |
| No accounts or login | **Optional** account. Skippable; the app works fully offline without one |
| No `INTERNET` in release builds | `INTERNET` is allowed. CI then checks that the **only** host contacted is the Supabase project URL |
| Nothing leaves the phone | Only **end-to-end encrypted** blobs leave the phone. The server holds ciphertext it cannot read |

These stay: no ads, no analytics on financial data, no AI calls, and raw SMS and notification text never leaves the phone (it is never synced).

## How it works

1. **Sign in:** an email code (built now); Google and Apple come next. Through Supabase Auth. The app never stores a password.
2. **Sync key:**
   - Made on the first phone: 256 random bits, kept in the Keystore or Keychain.
   - Shown once as a **recovery code** (53 characters in groups of four, with a typo check), which the user writes down.
   - A new phone needs the login **and** the recovery code. Losing the code means the cloud copy cannot be read; the phone's own data is unaffected.
3. **What is uploaded:**
   - each change (a payment added, edited or deleted; a Room, budget, rule or setting) becomes a small record, encrypted with AES-256-GCM using the sync key;
   - the server stores `(user id, record id, version, ciphertext, updated at)` and nothing else: no amounts, payees or categories.
4. **Sync:**
   - **when:** on open, after a change, and every 15 minutes while open;
   - **conflicts:** the last edit wins, per record;
   - **deletes** sync as tombstones.
5. **Offline first:** the phone's encrypted database stays the source of truth, and sync never blocks the app.
6. **Delete account:** removes every server row and the login. The phone keeps its local data.

## Build steps

1. Data model:
   - a `sync_changes` outbox;
   - `updated_at` and `deleted` on synced tables (schema v6, with a migration test).
2. Sync crypto: key, recovery code, record encryption (tests: wrong key, tampered record).
3. A sync engine against a fake server (push, pull, conflicts, tombstones, offline). Most of the tests live here.
4. Supabase client: Auth plus one `sync_records` table with row-level security, so a user can only read their own rows.
5. UI:
   - Settings → Account (sign in, recovery code, sync status, "Last synced 2 min ago", sign out, delete account);
   - an onboarding step offering sign-in (skippable).
6. Store and privacy:
   - update the privacy policy and the Play Data safety answers ("financial info: collected, encrypted in transit, end-to-end encrypted, deletable");
   - App Store label: "Data Linked to You: Financial Info, encrypted".
7. Tests:
   - two fake phones stay in step;
   - a new phone restores from the cloud;
   - the server sees only ciphertext.

## Status
- Built: steps 1–5 (email-code sign-in) and the docs.
- Next: Google and Apple sign-in, and an onboarding step.

## Supabase setup (once, in the dashboard)
1. **SQL Editor → New query:** paste `supabase/migrations/20261111000000_sync_records.sql` and press **Run**. It creates the `sync_records` table with row-level security, plus the `push_records` and `delete_my_account` functions.
2. **Authentication → Sign In / Providers → Email:** keep it on, and turn **"Confirm email" off**. The 6-digit code already proves the address; with it on, a new account gets a "Confirm your signup" email whose link points at the Site URL (a website, `localhost:3000` by default), not the app.
3. **Authentication → URL Configuration:** set **Site URL** to `expensetracker://login-callback` and add the same under **Redirect URLs**. The link in the email then opens the app and signs in.
3b. **Authentication → Emails → Templates → "Magic Link":** add the line `Your code: {{ .Token }}`, so the email carries the 6-digit code the app asks for.
4. **Authentication → Rate limits:** the built-in mailer sends only a few emails an hour. Before launch, set up your own SMTP under **Authentication → Emails → SMTP Settings** (for example Resend, Brevo or Amazon SES).

## What the owner had to do (done)

1. Create a free **Supabase** project at supabase.com. Pick the region **Mumbai (ap-south-1)**.
2. Send me the **Project URL** and the **anon public key**. That key is meant to be public; never send the `service_role` key.
3. To offer Google or Apple sign-in, set them up in the Supabase dashboard (I'll give the exact steps). Phone OTP needs an SMS provider such as Twilio or MSG91, which costs money per SMS. My recommendation: Google and Apple first.

## Costs
- Supabase free tier: 500 MB of database and 50,000 monthly active users, enough for a long time. The paid tier starts at about $25/month.
- Apple sign-in needs the paid Apple Developer account ($99/year), which you need to publish anyway.
