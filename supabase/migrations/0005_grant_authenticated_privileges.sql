-- =====================================================================
-- CA Desk — Grant base table privileges to `authenticated` (Hotfix)
-- =====================================================================
-- Root cause of "permission denied for table profiles" (Postgres error
-- 42501) on every read/write from the Flutter app:
--
-- RLS policies (0003_rls.sql) only decide *which rows* a role can see
-- once that role already has base object-level access to the table.
-- 0001_init.sql created every table but never ran a GRANT for the
-- `authenticated` role (the role Supabase's PostgREST/GoTrue assigns to
-- any signed-in user's JWT). Without that base GRANT, Postgres rejects
-- the query before RLS is even evaluated — this is true for every
-- table in `public`, not just `profiles`; it just surfaced first on
-- the Profile screen because that's the first authenticated read the
-- app does after sign-in.
--
-- This migration is idempotent — safe to re-run.
-- =====================================================================

-- Let the role see the schema at all.
grant usage on schema public to authenticated;

-- Base CRUD grant on every existing table. RLS policies (0003_rls.sql)
-- remain the real gate on which *rows* are visible/writable — this
-- only unblocks the table-level check that was missing.
grant select, insert, update, delete
  on all tables in schema public
  to authenticated;

-- Sequences (id defaults use gen_random_uuid() in this schema, so this
-- is mostly precautionary in case any table gains a serial/identity
-- column later).
grant usage, select on all sequences in schema public to authenticated;

-- Make sure any table added by a future migration gets the same base
-- grant automatically, so this specific bug can't recur.
alter default privileges in schema public
  grant select, insert, update, delete on tables to authenticated;

alter default privileges in schema public
  grant usage, select on sequences to authenticated;
