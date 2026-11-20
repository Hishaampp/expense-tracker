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
