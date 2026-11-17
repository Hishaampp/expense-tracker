"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { AmpleMark } from "@/components/brand/ample-mark";
import { AmplePour } from "@/components/brand/ample-lottie";
import { SignIn } from "@/components/gate/sign-in";
import { SplitFrame } from "@/components/gate/split-frame";
import { Unlock } from "@/components/gate/unlock";
import { Unlocking } from "@/components/gate/unlocking";
import { useSession } from "@/lib/session/session";
import { useVault } from "@/lib/vault/vault-context";

/** The front door: sign in, then unlock, then into the dashboard. */
export default function Gate() {
  const session = useSession();
  const { state, unlock } = useVault();
  const router = useRouter();

  useEffect(() => {
    if (state.status === "open") router.replace("/overview");
  }, [state.status, router]);

  if (session.status === "loading" || state.status === "open") {
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

  return (
    <SplitFrame art={<AmpleMark size={208} level={0} title={null} className="text-ink" />}>
      <Unlock
        email={session.session.user.email ?? "your account"}
        failure={state.failure}
        onUnlock={(key) => void unlock(key)}
      />
    </SplitFrame>
  );
}
