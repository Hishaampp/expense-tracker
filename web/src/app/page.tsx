"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { AmpleMark } from "@/components/brand/ample-mark";
import { AmplePour } from "@/components/brand/ample-lottie";
import { SignIn } from "@/components/gate/sign-in";
import { SplitFrame } from "@/components/gate/split-frame";
import { Unlock } from "@/components/gate/unlock";
import { Unlocking } from "@/components/gate/unlocking";
import { WelcomeBack } from "@/components/gate/welcome-back";
import { useSession } from "@/lib/session/session";
import { useVault } from "@/lib/vault/vault-context";

/** The front door: sign in, then unlock, then into the dashboard. */
export default function Gate() {
  const session = useSession();
  const { state, unlock, remembered, ready, unlockRemembered, forget } = useVault();
  const router = useRouter();

  useEffect(() => {
    if (state.status === "open") router.replace("/overview");
  }, [state.status, router]);

  // While a remembered key is tried, show the mark rather than the unlock screen.
  if (session.status === "loading" || state.status === "open" || (session.status === "signed-in" && !ready && state.status === "locked")) {
    return (
      <div className="grid min-h-dvh place-items-center text-ink" aria-busy>
        <AmpleMark size={56} sway title="Loading Ample" />
      </div>
    );
  }

  if (session.status === "signed-out") {
    return (
      <SplitFrame art={<AmplePour size={320} />}>
        <SignIn />
      </SplitFrame>
    );
  }

  if (state.status === "opening") {
    const progress = state.phase === "download" ? 0.12 : 0.12 + 0.88 * (state.total ? state.done / state.total : 0);
    return (
      <SplitFrame art={<AmpleMark size={208} level={progress} sway title={null} className="text-ink" />}>
        <Unlocking phase={state.phase} done={state.done} total={state.total} />
      </SplitFrame>
    );
  }

  if (remembered && (!state.failure || state.failure === "network")) {
    return (
      <SplitFrame art={<AmpleMark size={208} level={0} title={null} className="text-ink" />}>
        <WelcomeBack email={session.session.user.email ?? "your account"} until={remembered} offline={state.failure === "network"} onOpen={() => void unlockRemembered()} onForget={() => void forget()} />
      </SplitFrame>
    );
  }

  return (
    <SplitFrame art={<AmpleMark size={208} level={0} title={null} className="text-ink" />}>
      <Unlock
        email={session.session.user.email ?? "your account"}
        failure={state.failure}
        onUnlock={(key, remember) => void unlock(key, remember)}
      />
    </SplitFrame>
  );
}
