-- =====================================================================
-- CA Desk — Auth Trigger (Task 1 / Phase 3)
-- =====================================================================
-- Automatically creates a `profiles` row whenever a new user signs up
-- via Supabase Auth, reading full_name / phone / role / firm_id out of
-- auth.users.raw_user_meta_data.
--
-- This matches the metadata keys sent by AuthService.signUp() in
-- lib/features/auth/auth_service.dart:
--   { full_name, phone, role, firm_id }
--
-- Runs as SECURITY DEFINER so it can insert into `profiles` regardless
-- of RLS (added in 0003_rls.sql) — the trigger owner needs insert
-- rights on profiles, which it has since it's created by the project
-- owner/migration role.
-- =====================================================================

create or replace function handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_role user_role;
  v_firm_id uuid;
begin
  -- Default to 'client' if role missing or not a recognized value.
  begin
    v_role := coalesce(nullif(meta->>'role', ''), 'client')::user_role;
  exception when invalid_text_representation then
    v_role := 'client';
  end;

  -- firm_id is optional (e.g. a super_admin signing up with no firm yet).
  begin
    v_firm_id := nullif(meta->>'firm_id', '')::uuid;
  exception when invalid_text_representation then
    v_firm_id := null;
  end;

  insert into public.profiles (
    auth_user_id, full_name, email, phone, role, firm_id
  )
  values (
    new.id,
    meta->>'full_name',
    new.email,
    meta->>'phone',
    v_role,
    v_firm_id
  )
  -- Guards against the trigger firing twice for the same user
  -- (e.g. re-confirmation flows) without erroring the auth flow.
  on conflict (auth_user_id) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_auth_user();
