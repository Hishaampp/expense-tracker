import type { Metadata } from "next";
import Link from "next/link";
import { CONTACT_EMAIL, DEVELOPER, LegalPage } from "@/components/legal/legal-page";

export const metadata: Metadata = {
  title: "Privacy policy",
  description: "How Ample handles your data: on your phone by default, end-to-end encrypted if you turn on the optional account. No ads, no tracking.",
};

const mail = <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>;

/** The privacy policy for the Ample apps and website. Linked from the app and the store listings. */
export default function PrivacyPage() {
  return (
    <LegalPage
      title="Privacy policy"
      updated="19 November 2026"
      intro={
        <p>
          <strong>Short version:</strong> Ample keeps your money records on your phone. If you turn on the optional account, your records are locked on your phone
          before they are sent, so our server only holds data that no one can read, including us. No ads, no analytics, no tracking, and we never sell your data.
        </p>
      }
    >
      <h2>Who we are</h2>
      <p>
        Ample is an expense tracker made by {DEVELOPER} (&quot;we&quot;, &quot;us&quot;), an individual developer in India. This policy covers the Ample apps for
        Android and iPhone and the Ample website at ample-money.vercel.app. Questions or requests: {mail}.
      </p>

      <h2>Using Ample without an account</h2>
      <p>Ample works fully without an account. Then nothing you record leaves your phone, except files you choose to share yourself.</p>
      <h3>What Ample stores on your phone</h3>
      <ul>
        <li>Your payments and money in: amount, date, payee, category, account, Room (a trip or event) and note.</li>
        <li>Your budgets, Rooms, payee rules and settings.</li>
        <li>
          The original text of a captured payment message, for <strong>30 days</strong> by default, so a payment can be read again if Ample gets better at it. You can
          change this in Settings → Privacy &amp; data to &quot;Don&apos;t keep&quot; or &quot;Until I delete it&quot;.
        </li>
      </ul>
      <p>
        These are kept in Ample&apos;s private storage, which other apps can&apos;t read, and are protected by your phone&apos;s own encryption and screen lock.
        Ample never stores the content of personal chats, passwords or one-time codes.
      </p>
      <h3>What Ample reads, and only when you allow it</h3>
      <ul>
        <li>
          <strong>Payment notifications (Android, auto-capture):</strong> if you turn on auto-capture and give notification access, Ample reads notifications from
          the apps you choose (for example your SMS app, Google Pay, PhonePe or Paytm) to find the amount, payee and account of a payment. Notifications that
          aren&apos;t about a payment are ignored and not kept. This happens on your phone; nothing is sent anywhere. You can turn it off at any time.
        </li>
        <li>
          <strong>SMS:</strong> only the separately installed &quot;sideload&quot; Android version can read bank SMS, if you allow it. The version on Google Play
          does not ask for SMS permission.
        </li>
        <li>
          <strong>Messages you share or paste into Ample</strong>, and iPhone Shortcuts you set up yourself, are read the same way.
        </li>
        <li>
          <strong>Camera:</strong> only while you use Scan &amp; Pay (to read a UPI QR code) or Link a computer (to read the code on the Ample website). No picture is
          taken or kept.
        </li>
        <li>
          <strong>Face ID, fingerprint or passcode:</strong> for the optional app lock and to confirm linking a computer. Your phone checks it; Ample never sees your
          biometrics or passcode.
        </li>
      </ul>
      <h3>Scan &amp; Pay</h3>
      <p>
        Scan &amp; Pay reads the payee&apos;s name and UPI ID from a QR code, records the payment, and opens your UPI app (such as Google Pay, PhonePe, Paytm or
        BHIM), where you pay as usual with your UPI PIN. Ample never sees your PIN, never moves money, and is not told how the payment ended.
      </p>
      <h3>Notifications</h3>
      <p>Budget alerts and the weekly review are made and shown by your phone. Nothing is sent to us.</p>

      <h2>The optional account (sync)</h2>
      <p>If you choose to create an account, Ample keeps your records in step between your phones and lets you use the Ample website.</p>
      <ul>
        <li>
          <strong>Signing in:</strong> with your email (a one-time code; no password is stored), or with Google or Apple. We receive your email address and an account
          id from the sign-in. Google or Apple handle their own sign-in under their own privacy policies.
        </li>
        <li>
          <strong>End-to-end encryption:</strong> every record is encrypted on your phone (AES-256-GCM) with a key that only your devices have, before it is sent. The
          server cannot read your amounts, payees, categories or notes.
        </li>
        <li>
          <strong>What our server stores:</strong> your email address and account id; for each record a random-looking id, when it changed, and the encrypted data;
          and standard sign-in and security logs (such as time and IP address), kept by our hosting provider to protect your account.
        </li>
        <li>
          <strong>Recovery code:</strong> your key moves to a new phone only as a recovery code you keep. We never see it and cannot recover it for you. If you lose it,
          you can start sync over from a phone that still has your records.
        </li>
        <li>
          <strong>What never syncs:</strong> original message text, and phone-only settings such as the app lock.
        </li>
        <li>
          <strong>Deleting your account:</strong> Settings → Account &amp; sync → Delete account removes your login and every record on the server at once. The data
          on your phone stays.
        </li>
      </ul>

      <h2 id="delete-account">Deleting your account and data</h2>
      <ul>
        <li>
          <strong>In the app:</strong> Settings → Account &amp; sync → Delete account. Your login and every record on our server are deleted at once; a computer you
          linked can no longer sign in.
        </li>
        <li>
          <strong>Without the app:</strong> email {mail} from the address you signed in with, asking us to delete your account. We&apos;ll delete it and confirm
          within 30 days.
        </li>
        <li>
          <strong>On your phone:</strong> delete any record in the app, or uninstall Ample to remove everything it stored. A remembered computer is cleared with
          &quot;Forget this computer&quot;, by signing out, or after 30 days.
        </li>
      </ul>
      <p>Nothing is kept after deletion, apart from short-lived security logs held by our hosting providers.</p>

      <h2>The Ample website</h2>
      <ul>
        <li>
          <strong>Only your phone can sign a computer in.</strong> The website shows a one-time QR code. When you scan it with Ample on your signed-in phone and
          confirm, your phone hands that one browser tab a sealed pass: your key and a one-time sign-in for your own account. The pass is deleted from our server as
          soon as the tab collects it, or after two minutes.
        </li>
        <li>
          <strong>Your records open only in your browser.</strong> They arrive encrypted and are unlocked in the tab&apos;s memory. The tab locks after 15 minutes
          without use.
        </li>
        <li>
          <strong>Keep this computer unlocked (your choice):</strong> your key is stored in that browser, sealed so it can&apos;t be copied to another computer, for up
          to 30 days. &quot;Forget this computer&quot; or signing out removes it. Don&apos;t turn this on for a shared computer.
        </li>
        <li>
          <strong>Browser storage:</strong> the website also stores your sign-in session and your light or dark choice. It uses no advertising or tracking cookies.
        </li>
        <li>
          <strong>Exports:</strong> Excel, CSV and PDF files are made in your browser and saved where you choose. They are not encrypted, so keep them private.
        </li>
      </ul>

      <h2>Files you share yourself</h2>
      <ul>
        <li>
          <strong>Encrypted backup:</strong> a file locked with a password you choose (AES-256-GCM, with the key made from your password by PBKDF2). You decide where
          to save it.
        </li>
        <li>
          <strong>CSV, Excel and PDF exports:</strong> not encrypted. Ample warns you before you share them.
        </li>
      </ul>
      <p>Android&apos;s automatic cloud backup is turned off for Ample, so your records don&apos;t leave your phone that way.</p>

      <h2>Who else handles data</h2>
      <p>We use a few service providers, only to run Ample. They process data for us and may not use it for anything else.</p>
      <ul>
        <li>
          <strong>Supabase</strong> hosts the optional account: sign-in and the encrypted records, on servers in Sydney, Australia. So if you create an
          account, your email address and your encrypted records are stored outside India. The records stay end-to-end encrypted there and can&apos;t be read.
        </li>
        <li>
          <strong>Vercel</strong> hosts the Ample website. Like any website host, its servers see your IP address and the pages you ask for, in their logs.
        </li>
        <li>
          <strong>Google and Apple</strong>, only if you choose to sign in with them.
        </li>
      </ul>
      <p>
        We don&apos;t sell your data, share it for advertising, or use third-party analytics, crash reporting or tracking. We would only disclose data if the law
        requires it, and the encrypted records would still be unreadable.
      </p>

      <h2>How long we keep data</h2>
      <ul>
        <li>On your phone: until you delete it or uninstall Ample.</li>
        <li>On our server: until you delete your account. A computer-linking handover: at most two minutes.</li>
        <li>Security logs: for the short time our hosting providers keep them.</li>
      </ul>

      <h2>Your rights</h2>
      <p>
        Under India&apos;s Digital Personal Data Protection Act, 2023, and similar laws, you can ask to access, correct or erase your personal data, withdraw your
        consent, and raise a grievance. In Ample you can do most of this yourself: see and edit every record, export it, turn off auto-capture, sign out, or delete
        your account. For anything else, or a complaint, write to {mail} and we&apos;ll reply as soon as we can, within 30 days.
      </p>

      <h2>Children</h2>
      <p>Ample is meant for adults. If you are under 18, use it only with the permission of a parent or guardian.</p>

      <h2>Security</h2>
      <p>
        We use end-to-end encryption for synced records, TLS for every connection, and a strict security policy on the website. No system is perfectly secure, so
        please keep your phone locked, keep your recovery code safe, and tell us at {mail} if you find a problem.
      </p>

      <h2>Changes to this policy</h2>
      <p>If we change this policy, we&apos;ll update the date above, and tell you in the app if the change matters to how your data is used.</p>

      <h2>Contact</h2>
      <p>
        {DEVELOPER}, {mail}. See also our <Link href="/terms">terms of use</Link>.
      </p>
    </LegalPage>
  );
}
