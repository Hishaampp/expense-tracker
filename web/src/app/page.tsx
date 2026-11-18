"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { AmpleMark } from "@/components/brand/ample-mark";
import { AmplePour } from "@/components/brand/ample-lottie";
import { SplitFrame } from "@/components/gate/split-frame";
import { Unlock } from "@/components/gate/unlock";
import { Unlocking } from "@/components/gate/unlocking";
import { WelcomeBack } from "@/components/gate/welcome-back";
import { cloud } from "@/lib/cloud/client";
import type { PhonePass } from "@/lib/link/link-crypto";
import { useSession } from "@/lib/session/session";
import { useVault } from "@/lib/vault/vault-context";

/**
 * The front door. Only a signed-in phone lets a computer in: its scan
 * brings a one-time sign-in and the key, so this page signs in and
 * unlocks in one step. A remembered computer opens straight away.
 */
export default function Gate() {
  const session = useSession();
  const { state, unlock, fail, remembered, ready, unlockRemembered, forget } = useVault();
  const router = useRouter();
  const [signingIn, setSigningIn] = useState(false);

  useEffect(() => {
    if (state.status === "open") router.replace("/overview");
  }, [state.status, router]);

  const user = session.status === "signed-in" ? session.session.user : null;

  const enter = async (pass: PhonePass, remember: boolean) => {
    setSigningIn(true);
    try {
      let userId = user?.id;
      // Sign in with the phone's one-time token, unless already signed in as that account.
      if (!user || (user.email ?? "").toLowerCase() !== pass.email.toLowerCase()) {
        const { data, error } = await cloud().auth.verifyOtp({ token_hash: pass.tokenHash, type: "magiclink" });
        if (error || !data.user) {
          fail("sign-in");
          return;
        }
        userId = data.user.id;
      }
      await unlock(pass.key, remember, userId);
    } finally {
      setSigningIn(false);
    }
  };

  // While a remembered key is tried, show the mark rather than the QR.
  if (session.status === "loading" || state.status === "open" || (user && !ready && state.status === "locked")) {
    return (
      <div className="grid min-h-dvh place-items-center text-ink" aria-busy>
        <AmpleMark size={56} sway title="Loading Ample" />
      </div>
    );
  }

  if (state.status === "opening" || signingIn) {
    const progress = state.status !== "opening" ? 0.04 : state.phase === "download" ? 0.12 : 0.12 + 0.88 * (state.total ? state.done / state.total : 0);
    return (
      <SplitFrame art={<AmpleMark size={208} level={progress} sway title={null} className="text-ink" />}>
        <Unlocking phase={state.status === "opening" ? state.phase : "download"} done={state.status === "opening" ? state.done : 0} total={state.status === "opening" ? state.total : 0} />
      </SplitFrame>
    );
  }

  if (user && remembered && (!state.failure || state.failure === "network")) {
    return (
      <SplitFrame art={<AmpleMark size={208} level={0} title={null} className="text-ink" />}>
        <WelcomeBack email={user.email ?? "your account"} until={remembered} offline={state.failure === "network"} onOpen={() => void unlockRemembered()} onForget={() => void forget()} />
      </SplitFrame>
    );
  }

  return (
    <SplitFrame art={user ? <AmpleMark size={208} level={0} title={null} className="text-ink" /> : <AmplePour size={320} />}>
      <Unlock email={user?.email ?? null} failure={state.status === "locked" ? state.failure : undefined} onPass={(pass, remember) => void enter(pass, remember)} />
    </SplitFrame>
  );
}
