import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { CLOUD_PUBLISHABLE_KEY, CLOUD_URL } from "./config";

let client: SupabaseClient | null = null;

/** The one Supabase client for this tab (browser only). */
export function cloud(): SupabaseClient {
  client ??= createClient(CLOUD_URL, CLOUD_PUBLISHABLE_KEY, {
    auth: { flowType: "pkce", persistSession: true, detectSessionInUrl: true },
  });
  return client;
}

/** Where a sign-in link or Google returns to: this site's start page. */
export function signInReturnUrl(): string {
  return `${window.location.origin}/`;
}
