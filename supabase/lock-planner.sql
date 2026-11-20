-- Staffing Planner: lock its data to the Jobsite Schedule's sign-in. Run once in Supabase → SQL Editor,
-- AFTER the new page (with the sign-in screen instead of the passcode) is live. Safe to run again.
--
-- Before this, the planner's tables answered anyone holding the public key in the page. After it, only
-- the schedule board's shared login (scheduler@bancroftconstruction.com) can read or change them.
-- Tables: public.plan (the live plan, id 1, plus id 0) and public.plan_history (saved versions).

do $$
declare t text; p record; s record;
begin
  foreach t in array array['plan','plan_history'] loop
    -- remove every existing policy (the old open ones), whatever they were called
    for p in select policyname from pg_policies where schemaname='public' and tablename=t loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;

    execute format('revoke all on public.%I from anon', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format('alter table public.%I enable row level security', t);

    execute format($f$create policy "schedule login read" on public.%I for select to authenticated
      using (lower(auth.jwt() ->> 'email') = 'scheduler@bancroftconstruction.com')$f$, t);
    execute format($f$create policy "schedule login insert" on public.%I for insert to authenticated
      with check (lower(auth.jwt() ->> 'email') = 'scheduler@bancroftconstruction.com')$f$, t);
    execute format($f$create policy "schedule login update" on public.%I for update to authenticated
      using (lower(auth.jwt() ->> 'email') = 'scheduler@bancroftconstruction.com')
      with check (lower(auth.jwt() ->> 'email') = 'scheduler@bancroftconstruction.com')$f$, t);
    execute format($f$create policy "schedule login delete" on public.%I for delete to authenticated
      using (lower(auth.jwt() ->> 'email') = 'scheduler@bancroftconstruction.com')$f$, t);

    -- id counters (if any) used when saving versions
    for s in select c.relname from pg_class c join pg_depend d on d.objid=c.oid
             where c.relkind='S' and d.refobjid=('public.'||t)::regclass loop
      execute format('revoke all on sequence public.%I from anon', s.relname);
      execute format('grant usage, select on sequence public.%I to authenticated', s.relname);
    end loop;
  end loop;
end $$;
