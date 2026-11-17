"use client";

import type { Session } from "@supabase/supabase-js";
import { createContext, useContext, useEffect, useState } from "react";
import { cloud } from "@/lib/cloud/client";

type SessionState =
  | { status: "loading" }
  | { status: "signed-out" }
  | { status: "signed-in"; session: Session };

const SessionContext = createContext<SessionState>({ status: "loading" });

/** The Supabase sign-in, shared with the app's account. */
export function SessionProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<SessionState>({ status: "loading" });

  useEffect(() => {
    const db = cloud();
    let active = true;
    db.auth.getSession().then(({ data }) => {
      if (!active) return;
      setState(data.session ? { status: "signed-in", session: data.session } : { status: "signed-out" });
    });
    const { data } = db.auth.onAuthStateChange((_event, session) => {
      setState(session ? { status: "signed-in", session } : { status: "signed-out" });
    });
    return () => {
      active = false;
      data.subscription.unsubscribe();
    };
  }, []);

  return <SessionContext.Provider value={state}>{children}</SessionContext.Provider>;
}

export const useSession = () => useContext(SessionContext);
