# Store readiness notes (Phase 8)

## Before publishing: decisions only the owner can make

1. **Final app name and IDs.** Change these in one place each:
   - `android/app/build.gradle.kts`: `appApplicationId` and `appDisplayName`;
   - `ios/Flutter/AppIdentity.xcconfig`: `APP_BUNDLE_ID`;
   - `lib/core/app_identity.dart`.

   The Android ID can never change after the first upload. Check the name for trademarks and check that it is free in both stores.
2. A contact email for the privacy policy and the store listings.
3. A release signing key (Android) and an App Store Connect account (iOS).

## Google Play: Data safety form

| Question | Answer | Why |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes, collected only** (Phase 9) | Only when the user turns on the optional account. **Personal info:** email address (for account management). **Financial info:** purchase history, end-to-end encrypted, so the server cannot read it. Nothing is shared with third parties. |
| Is the data processed ephemerally? | No | Kept until the user deletes their account. |
| Is collection required? | **No, optional** | The app works fully without an account. |
| Is all user data encrypted in transit? | Yes | TLS only (cleartext is blocked by a CI check). Records are also end-to-end encrypted. |
| Do you provide a way for users to request that their data be deleted? | Yes | Settings → Account & sync → Delete account removes the login and every server record at once. |

The user can export a backup or CSV file and share it through the system share sheet. Play treats that as user-initiated sharing, not collection. Mention it in the listing.

### Sensitive permissions and declarations
- **Notification listener (`BIND_NOTIFICATION_LISTENER_SERVICE`):**
  - Declare it as the app's core feature: automatic expense tracking from payment notifications.
  - Before the user opens system settings, the in-app disclosure (Settings → Auto-capture) says which apps are read, what is kept, and that nothing leaves the phone.
- **SMS (`READ_SMS`, `RECEIVE_SMS`):** only in the **sideload** flavor, which is **not** uploaded to Play. The `play` flavor's merged manifest is checked in CI to contain neither.
- **`POST_NOTIFICATIONS`:** budget alerts and the weekly review.
- **`USE_BIOMETRIC`:** the optional app lock.
- **`RECEIVE_BOOT_COMPLETED`:** keeps capture and the Sunday review scheduled after a restart.

### Prominent disclosure (shown before notification access)
> To record payments for you, Expenses reads notifications from the apps you choose, like your SMS app and UPI apps. It only keeps the amount, payee and account of payments; other notifications are ignored and personal chats are never saved. Everything stays on this phone.

## App Store: privacy label ("nutrition label")
- **Data Linked to You** (only with the optional account): **Contact Info: Email Address** (App Functionality); **Financial Info: Other Financial Info** (App Functionality, end-to-end encrypted).
- **Tracking:** No.
- **Face ID:** `NSFaceIDUsageDescription` explains the app lock.
- **App Review notes:**
  - Shortcuts-based capture (spec §6.3): the user builds a personal automation that passes bank message text to the app's App Intent. The app has no network access.
  - Include a short screen recording of the Shortcuts setup.

## Screenshot list (both stores, 6.7" iPhone and a 1080×2400 Android phone)
1. **Home:** "You've spent ₹18,240 this month", the budget ring with *Safe to spend today ₹1,090*, and active Room chips.
2. **Review inbox:** captured payments with suggested categories and "Always use this category for Swiggy".
3. **A Room (Goa trip):** total, per day, budget bar, and the day-by-day list.
4. **Stats:** the category donut, the day-by-day bars and the last 6 months.
5. **Budgets:** monthly and category budgets, with one shown over budget.
6. **Weekly review:** this week against last week, top payees, and "One thing to watch".
7. **Privacy:** the onboarding privacy card ("Your money stays on your phone") or Settings → Privacy & data.
8. *(Android only)* Auto-capture setup with the disclosure.

Use realistic but fake data: seed a demo database, never a real account.

## Release checklist
- [ ] `tool/ci.sh` passes. Its manifest gate checks that release builds have no `INTERNET` and that the play flavor has no SMS permissions.
- [ ] Design review run on a release build (spec §11.1 F), with no open BLOCKERs.
- [ ] A restore on a fresh install reproduces all data (automated: `test/data/backup_codec_test.dart`; also check by hand once on a device).
- [ ] Final name and IDs set; signing configured; version bumped.
