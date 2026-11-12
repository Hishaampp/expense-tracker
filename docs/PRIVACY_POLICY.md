# Privacy policy (draft)

*App: "Expenses" (placeholder name until the final name is chosen). Last updated: 11 November 2026.*

**Short version: everything stays on your phone, unless you turn on the optional account. If you do, your data is locked on your phone before it is sent, so the server only holds data no one can read, including us. No ads, no analytics, no tracking.**

## What the app reads

- **Payment notifications** (Android, only if you turn on auto-capture), from the apps you choose: your SMS app, Google Pay, PhonePe, Paytm and similar.
  - The app reads a notification only to find the amount, the payee and the account of a payment.
  - Personal chats are never stored. Notifications that are not about a payment are thrown away.
- **SMS** (Android "sideload" version only, if you allow it): bank messages, read the same way.
- **Messages you share or paste into the app**, and **iPhone Shortcuts** you set up yourself.
- **The camera**, only while you use **Scan & Pay**, to read a UPI QR code. No picture is taken or kept; the app reads the payee's name and UPI ID from the code.
- **Scan & Pay** opens your UPI app (Google Pay, PhonePe, Paytm or BHIM) with the payment filled in. You pay there with your UPI PIN; this app never sees your PIN and never moves money. On Android your UPI app tells this app whether the payment went through.

## What the app stores, and where

- **Where:** only on your phone, in an encrypted database. The key is in your phone's secure storage: the Android Keystore or the iOS Keychain.
- **What it stores:**
  - your payments: amount, date, payee, category, account, Room and note;
  - your budgets, Rooms, payee rules and settings.
- **Original message text** is kept for **30 days** by default, so a payment can be read again if the app improves. In Settings → Privacy & data you can change this to "Don't keep" or "Until I delete it".
- **What it never stores:** the content of personal chats, and passwords or one-time codes.

## The optional account (sync)

- **Without an account,** nothing leaves your phone and the app works fully.
- **If you sign in** with your email (a one-time code; no password is stored), the app syncs your data between your phones through our server, hosted by Supabase in Mumbai, India.
- **What is sent:** every synced record is **encrypted on your phone** (AES-256-GCM) with a key only your phones have. The server stores only:
  - your email address (for the login);
  - for each record: a random-looking id, when it changed, and the encrypted data.
- **What we cannot see:** your amounts, payees, categories or anything else.
- **The recovery code:** the key moves to a new phone only as a recovery code you write down. We never see it and cannot recover it for you.
- **What never syncs:** original bank message text, and phone-only settings such as the app lock.
- **Deleting it:** "Delete account" in the app removes your login and every record on the server at once. The data on your phone stays.

## What else leaves your phone

**Nothing, unless you send it yourself:**
- **Encrypted backup:** a file locked with a password you choose (AES-256-GCM, with the key derived from your password by PBKDF2). You decide where to save it: Files, Google Drive, iCloud and so on. Without the password the file can't be read.
- **CSV export:** a spreadsheet of your payments. It is **not encrypted**, and the app warns you before you share it.

Apart from the optional account above, the app sends nothing to us or to anyone else. There are no ads and no third-party analytics, crash reporting or tracking.

## Notifications and the app lock

- **Notifications:** budget alerts and the weekly review are made on your phone and shown by your phone.
- **App lock:** uses your phone's own Face ID, fingerprint or passcode. The app never sees your biometrics or your passcode.

## Your choices

- Turn off auto-capture at any time, in Settings or in your phone's notification access settings.
- Delete any payment, or uninstall the app to delete everything.
- Android's automatic cloud backup is turned off for this app. Your data moves to a new phone only through your own encrypted backup.

## Children

This app is not made for children under 13.

## Contact

[Owner to add a contact email before publishing.]
