-- Ample: everything a new Supabase project needs, in order (the 3 migrations).
-- Paste into SQL Editor -> New query -> Run, once. Safe to run again.

-- ===== 20261111000000_sync_records.sql =====
-- Phase 9: end-to-end encrypted sync. The server stores sealed records it
-- cannot read: per user, an opaque id, a change time and ciphertext.
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.

create sequence if not exists public.sync_seq;

create table if not exists public.sync_records (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  id text not null check (id ~ '^[0-9a-f]{64}$'),
  changed_at bigint not null,
  blob text not null check (length(blob) < 200000),
  seq bigint not null,
  primary key (user_id, id)
);

create index if not exists sync_records_user_seq
  on public.sync_records (user_id, seq);

-- Every row belongs to one user, and only that user can see or change it.
alter table public.sync_records enable row level security;

drop policy if exists "read own records" on public.sync_records;
create policy "read own records" on public.sync_records
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "add own records" on public.sync_records;
create policy "add own records" on public.sync_records
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "change own records" on public.sync_records;
create policy "change own records" on public.sync_records
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "delete own records" on public.sync_records;
create policy "delete own records" on public.sync_records
  for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.sync_records to authenticated;
grant usage on sequence public.sync_seq to authenticated;

-- Stores records, keeping per id only the newest change. Runs as the
-- calling user, so the policies above still apply.
create or replace function public.push_records(records jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.sync_records as r (user_id, id, changed_at, blob, seq)
  select auth.uid(),
         x ->> 'id',
         (x ->> 'changed_at')::bigint,
         x ->> 'blob',
         nextval('public.sync_seq')
  from jsonb_array_elements(records) as x
  on conflict (user_id, id) do update
    set changed_at = excluded.changed_at,
        blob = excluded.blob,
        seq = excluded.seq
    where r.changed_at < excluded.changed_at;
end;
$$;

revoke all on function public.push_records(jsonb) from public, anon;
grant execute on function public.push_records(jsonb) to authenticated;

-- Deletes the calling user's account; their records go with it.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- ===== 20261117000000_link_computer.sql =====
-- Ample for the web, W2: link a computer by QR (docs/WEB_DASHBOARD_PLAN.md).
-- The website shows a QR with a one-time id and a one-time public key. The
-- phone, signed in to the same account, seals the sync key for that public
-- key and leaves it here; the website reads it and deletes it. The server
-- only ever holds a sealed key it cannot open.
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.

create table if not exists public.link_requests (
  id text primary key check (id ~ '^[0-9a-f]{32}$'),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  phone_key text not null check (length(phone_key) < 100),
  sealed text not null check (length(sealed) < 200),
  created_at timestamptz not null default now()
);

alter table public.link_requests enable row level security;

-- Only the same account can leave or read a handover, and only for two
-- minutes; after that it is as good as gone.
drop policy if exists "add own link" on public.link_requests;
create policy "add own link" on public.link_requests
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "read own fresh link" on public.link_requests;
create policy "read own fresh link" on public.link_requests
  for select to authenticated
  using (
    (select auth.uid()) = user_id
    and created_at > now() - interval '2 minutes'
  );

drop policy if exists "delete own link" on public.link_requests;
create policy "delete own link" on public.link_requests
  for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, delete on public.link_requests to authenticated;

-- Old handovers are cleared whenever a new one is left.
create or replace function public.clear_old_links()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  delete from public.link_requests
  where user_id = auth.uid() and created_at < now() - interval '10 minutes';
  return new;
end;
$$;

drop trigger if exists clear_old_links on public.link_requests;
create trigger clear_old_links
  before insert on public.link_requests
  for each row execute function public.clear_old_links();

-- ===== 20261119000000_phone_only_web_sign_in.sql =====
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
