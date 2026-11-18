// Ample for the web: a one-time sign-in for a computer, asked for by the
// signed-in phone (supabase/migrations/20261119000000_phone_only_web_sign_in.sql).
//
// The caller must be signed in (the gateway checks the token; this checks
// it again and reads who it is). It gets a magic-link token for its own
// account only; nothing is emailed. The phone seals the token for the one
// browser tab that showed the QR, which exchanges it for its own session.
// Deploy: supabase functions deploy link-session
import { createClient } from "jsr:@supabase/supabase-js@2";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "not-signed-in" }, 401);

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: who, error } = await admin.auth.getUser(token);
  const email = who?.user?.email;
  if (error || !email) return json({ error: "not-signed-in" }, 401);

  const { data, error: linkError } = await admin.auth.admin.generateLink({ type: "magiclink", email });
  const tokenHash = data?.properties?.hashed_token;
  if (linkError || !tokenHash) return json({ error: "unavailable" }, 500);
  return json({ email, token_hash: tokenHash });
});
