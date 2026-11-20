import type { Metadata } from "next";
import Link from "next/link";
import { CONTACT_EMAIL, DEVELOPER, LegalPage } from "@/components/legal/legal-page";

export const metadata: Metadata = {
  title: "Terms of use",
  description: "The terms for using the Ample apps and website.",
};

const mail = <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>;

/** The terms of use for the Ample apps and website. Linked from the app and the store listings. */
export default function TermsPage() {
  return (
    <LegalPage
      title="Terms of use"
      updated="19 November 2026"
      intro={
        <p>
          <strong>Short version:</strong> Ample helps you keep track of your own money. It isn&apos;t a bank, a payment service or a financial adviser. It&apos;s free,
          it&apos;s provided as it is, and your records stay yours. Please check what Ample records, and keep your phone and recovery code safe.
        </p>
      }
    >
      <h2>1. Agreeing to these terms</h2>
      <p>
        These terms are between you and {DEVELOPER} (&quot;we&quot;, &quot;us&quot;), who makes Ample. By using the Ample apps for Android and iPhone or the Ample
        website at ample-money.vercel.app (together, &quot;Ample&quot;), you agree to them. If you don&apos;t agree, please don&apos;t use Ample. Our{" "}
        <Link href="/privacy">privacy policy</Link> explains how your data is handled and is part of these terms.
      </p>

      <h2>2. What Ample is, and isn&apos;t</h2>
      <ul>
        <li>Ample is a personal expense tracker: it records, sorts and summarises payments and money in, for your own use.</li>
        <li>
          <strong>Ample isn&apos;t a bank, a payment service or a financial adviser.</strong> It never holds or moves money. Budgets, &quot;safe to spend&quot; and
          other figures are estimates from your own records, not financial, tax or legal advice.
        </li>
        <li>
          <strong>Scan &amp; Pay</strong> opens your own UPI app to make a payment. That payment is between you, your bank and your UPI app, under their terms. Ample
          isn&apos;t responsible for it, and isn&apos;t told whether it succeeded.
        </li>
      </ul>

      <h2>3. Check your records</h2>
      <p>
        Auto-capture reads payment messages automatically and can misread or miss some, for example when a bank changes how its messages look. Ample shows you
        what it captured so you can review it. You are responsible for checking your records before relying on them, for example for taxes, claims or decisions.
      </p>

      <h2>4. Your account and devices</h2>
      <ul>
        <li>The account is optional. If you create one, keep the phone you sign in on locked and secure: only a signed-in phone can sign in a computer.</li>
        <li>
          <strong>Your recovery code is the only way to open your synced records on a new phone.</strong> We never see it and can&apos;t recover it. If it&apos;s
          lost, records that exist only on our server can&apos;t be opened by anyone; records on your phone are not affected.
        </li>
        <li>
          Choosing &quot;Keep this computer unlocked&quot; means anyone using that browser can open your records until you lock it, forget it, or 30 days pass. Use it
          only on a computer you trust.
        </li>
        <li>You are responsible for activity on your devices and for keeping exported files private.</li>
      </ul>

      <h2>5. Fair use</h2>
      <p>Please don&apos;t:</p>
      <ul>
        <li>use Ample for anything unlawful, or to record other people&apos;s data without their permission;</li>
        <li>try to get into accounts or data that aren&apos;t yours, or to break or get around Ample&apos;s security;</li>
        <li>overload, disrupt or misuse our servers, for example with automated requests;</li>
        <li>copy, resell or pass off Ample as your own.</li>
      </ul>
      <p>We may suspend or close an account that breaks these rules, to protect other users and the service.</p>

      <h2>6. Your data</h2>
      <p>
        Your records belong to you. You can export them or delete them at any time, and delete your account from the app. We don&apos;t sell your data or use it for
        advertising. The <Link href="/privacy">privacy policy</Link> has the details.
      </p>

      <h2>7. Price and changes to Ample</h2>
      <p>
        Ample is free today. We may change, add or remove features, or stop offering part of Ample, and we&apos;ll give notice in the app where reasonable. If we ever
        start charging for something, we&apos;ll tell you first, and it won&apos;t apply unless you agree.
      </p>

      <h2>8. Other services</h2>
      <p>
        Ample works with other services, such as your UPI app, your bank&apos;s messages, Google or Apple sign-in, and the companies that host our servers. Their own
        terms apply to them, and we aren&apos;t responsible for how they work.
      </p>

      <h2>9. No warranty</h2>
      <p>
        We work hard to make Ample accurate and reliable, but it is provided &quot;as is&quot; and &quot;as available&quot;, without warranties of any kind, to the
        extent the law allows. We don&apos;t promise that it will be error-free or always available, or that it will capture every payment.
      </p>

      <h2>10. Limits on our responsibility</h2>
      <p>
        To the extent the law allows, we aren&apos;t liable for indirect or consequential losses, or for losses caused by misread or missing records, payments made
        through other apps, lost recovery codes or devices, or files you share. Nothing in these terms limits any right you have that the law doesn&apos;t allow us
        to limit.
      </p>

      <h2>11. Ending</h2>
      <p>
        You can stop using Ample at any time: delete your account in the app and uninstall it. These terms stop applying then, apart from the parts that by their
        nature should continue (such as sections 9 and 10).
      </p>

      <h2>12. Changes to these terms</h2>
      <p>
        If we change these terms, we&apos;ll update the date above and, for important changes, tell you in the app. Continuing to use Ample after a change means you
        accept the new terms.
      </p>

      <h2>13. Law</h2>
      <p>These terms are governed by the laws of India, and the courts of India have jurisdiction over any dispute.</p>

      <h2>14. Contact</h2>
      <p>
        Questions, complaints or grievances: {DEVELOPER}, {mail}.
      </p>
    </LegalPage>
  );
}
