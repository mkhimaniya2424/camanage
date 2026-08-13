-- =====================================================================
-- CA Desk — Seed Data (Task 1 / Phase 3)
-- =====================================================================
-- For local testing only. Creates one firm, one CA owner profile, one
-- staff profile, one client (business record + linked profile).
--
-- NOTE: profiles.auth_user_id must reference a real row in auth.users.
-- You cannot insert into auth.users directly via SQL in Supabase's
-- hosted product — create these test users first via the Supabase
-- Auth dashboard (or sign up through the app) using the role/firm_id
-- metadata described in 0002_auth_trigger.sql, then this script's
-- profile inserts become unnecessary (the trigger already created
-- them). This file is provided for local/self-hosted Supabase (CLI)
-- where auth.users can be seeded directly.
-- =====================================================================

-- Test firm
insert into firms (id, firm_name, registration_number, email, phone, city, state, subscription_plan, subscription_status)
values (
  '00000000-0000-0000-0000-000000000001',
  'Sharma & Associates',
  'REG-TEST-001',
  'contact@sharmaca.test',
  '9999900000',
  'Mumbai',
  'Maharashtra',
  'free',
  'active'
)
on conflict (id) do nothing;

-- Test auth users (Supabase CLI / local Postgres only — see note above).
-- Passwords: all 'password123' (bcrypt not needed here; Supabase Auth
-- hosted product manages auth.users directly, this is illustrative for
-- `supabase start` local dev where you seed via the CLI's auth helpers
-- instead of raw SQL in practice).

-- CA owner profile (assumes auth user already exists with this id)
insert into profiles (id, auth_user_id, full_name, email, phone, role, firm_id, is_active)
values (
  '00000000-0000-0000-0000-000000000101',
  '00000000-0000-0000-0000-000000000101',
  'Rina Sharma',
  'rina@sharmaca.test',
  '9999900001',
  'ca',
  '00000000-0000-0000-0000-000000000001',
  true
)
on conflict (id) do nothing;

-- Staff profile
insert into profiles (id, auth_user_id, full_name, email, phone, role, firm_id, is_active)
values (
  '00000000-0000-0000-0000-000000000102',
  '00000000-0000-0000-0000-000000000102',
  'Amit Verma',
  'amit@sharmaca.test',
  '9999900002',
  'staff',
  '00000000-0000-0000-0000-000000000001',
  true
)
on conflict (id) do nothing;

-- Client profile (login account for the client)
insert into profiles (id, auth_user_id, full_name, email, phone, role, firm_id, is_active)
values (
  '00000000-0000-0000-0000-000000000103',
  '00000000-0000-0000-0000-000000000103',
  'Priya Patel',
  'priya@client.test',
  '9999900003',
  'client',
  '00000000-0000-0000-0000-000000000001',
  true
)
on conflict (id) do nothing;

-- Client business record, linked to the client's profile
insert into clients (id, firm_id, name, client_type, email, phone, pan_number, gstin, status, profile_id)
values (
  '00000000-0000-0000-0000-000000000201',
  '00000000-0000-0000-0000-000000000001',
  'Priya Patel',
  'individual',
  'priya@client.test',
  '9999900003',
  'ABCDE1234F',
  '27ABCDE1234F1Z5',
  'active',
  '00000000-0000-0000-0000-000000000103'
)
on conflict (id) do nothing;
