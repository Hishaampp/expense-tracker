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
