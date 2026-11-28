-- Review/back up existing policies before running. This replaces ALL policies
-- on public.problems to prevent older permissive policies bypassing ownership.
begin;
alter table public.problems add column if not exists user_id uuid references auth.users(id);
create index if not exists problems_user_id_idx on public.problems(user_id);
alter table public.problems enable row level security;

do $$
declare p record;
begin
    for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'problems' loop
        execute format('drop policy %I on public.problems', p.policyname);
    end loop;
end $$;

create policy "Users read their own problems" on public.problems for select to authenticated
    using ((select auth.uid()) = user_id);
create policy "Users create their own problems" on public.problems for insert to authenticated
    with check ((select auth.uid()) = user_id);
create policy "Users update their own problems" on public.problems for update to authenticated
    using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users delete their own problems" on public.problems for delete to authenticated
    using ((select auth.uid()) = user_id);
commit;