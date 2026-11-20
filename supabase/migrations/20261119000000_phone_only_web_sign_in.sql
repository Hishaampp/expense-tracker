-- Ample for the web: only a signed-in phone can sign a computer in.
-- The website has no sign-in of its own any more. It shows a QR with a
-- one-time id (128 random bits, known only to that browser tab and the
-- phone that scans it) and a one-time public key. The phone leaves, sealed
-- for that key, the sync key and a one-time sign-in token made for its own
-- account by the link-session function. The signed-out tab collects it
-- with the id; nobody without the id can, and the sealed text is useless
-- to anyone but that tab.
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.

-- The sealed handover now carries the sign-in token too.
alter table public.link_requests drop constraint if exists link_requests_sealed_check;
alter table public.link_requests
  add constraint link_requests_sealed_check check (length(sealed) < 2000);

-- Collect (and remove) a fresh handover by its id, signed in or not.
create or replace function public.claim_link_request(request_id text)
returns table (phone_key text, sealed text)
language sql
security definer
set search_path = ''
as $$
  delete from public.link_requests r
  where r.id = request_id
    and r.created_at > now() - interval '2 minutes'
  returning r.phone_key, r.sealed;
$$;

revoke all on function public.claim_link_request(text) from public;
grant execute on function public.claim_link_request(text) to anon, authenticated;
