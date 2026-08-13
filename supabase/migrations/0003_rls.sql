-- =====================================================================
-- CA Desk — Row Level Security (Task 2 / Phase 4)
-- =====================================================================
-- Run after 0001_init.sql and 0002_auth_trigger.sql.
--
-- Roles (profiles.role, enum user_role): super_admin, ca, staff, client
-- NOTE: the original task prompt referred to "ca_owner" — the actual
-- schema (0001_init.sql) defines the enum value as 'ca'. This file uses
-- 'ca' to match the real schema.
--
-- Design:
--   - Helper functions are SECURITY DEFINER + STABLE so they can read
--     `profiles`/`clients` internally without triggering RLS recursion
--     (a policy on `profiles` calling a function that itself queries
--     `profiles` under RLS would deadlock/recurse otherwise).
--   - search_path is pinned on every SECURITY DEFINER function to avoid
--     search-path hijacking.
--   - Table owner (postgres/supabase admin role used by migrations)
--     bypasses RLS by default — only `anon`/`authenticated` roles used
--     by the Flutter app are restricted by these policies.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------------------

create or replace function public.current_profile_id()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select id from profiles where auth_user_id = auth.uid();
$$;

create or replace function public.current_role()
returns user_role
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select role from profiles where auth_user_id = auth.uid();
$$;

create or replace function public.current_firm_id()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select firm_id from profiles where auth_user_id = auth.uid();
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    (select role = 'super_admin' from profiles where auth_user_id = auth.uid()),
    false
  );
$$;

create or replace function public.is_firm_staff_or_owner()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    (select role in ('ca', 'staff') from profiles where auth_user_id = auth.uid()),
    false
  );
$$;

-- The clients.id row linked to the currently-logged-in client user
-- (via clients.profile_id -> profiles.id). Null for non-client roles
-- or clients with no linked login yet.
create or replace function public.current_client_id()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select id from clients where profile_id = public.current_profile_id();
$$;

grant execute on function public.current_profile_id() to authenticated;
grant execute on function public.current_role() to authenticated;
grant execute on function public.current_firm_id() to authenticated;
grant execute on function public.is_super_admin() to authenticated;
grant execute on function public.is_firm_staff_or_owner() to authenticated;
grant execute on function public.current_client_id() to authenticated;

-- =====================================================================
-- profiles
-- =====================================================================
alter table profiles enable row level security;

create policy profiles_select on profiles for select
using (
  is_super_admin()
  or auth_user_id = auth.uid()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

-- Fallback self-insert path (normal signup goes through the
-- SECURITY DEFINER trigger in 0002, which bypasses RLS entirely).
create policy profiles_insert on profiles for insert
with check (
  is_super_admin()
  or auth_user_id = auth.uid()
);

create policy profiles_update on profiles for update
using (
  is_super_admin()
  or auth_user_id = auth.uid()
  or (firm_id = current_firm_id() and current_role() = 'ca')
)
with check (
  is_super_admin()
  or auth_user_id = auth.uid()
  or (firm_id = current_firm_id() and current_role() = 'ca')
);

create policy profiles_delete on profiles for delete
using (is_super_admin());

-- =====================================================================
-- firms
-- =====================================================================
alter table firms enable row level security;

create policy firms_select on firms for select
using (
  is_super_admin()
  or id = current_firm_id()
);

-- ASSUMPTION (flagged per Task 2 instructions — table wasn't explicit
-- on firm self-creation at signup): only super_admin can create new
-- firm rows. If you want a "CA signs up and creates their own firm"
-- flow, tell me and I'll add an insert policy for that case.
create policy firms_insert on firms for insert
with check (is_super_admin());

create policy firms_update on firms for update
using (
  is_super_admin()
  or (id = current_firm_id() and current_role() = 'ca')
)
with check (
  is_super_admin()
  or (id = current_firm_id() and current_role() = 'ca')
);

create policy firms_delete on firms for delete
using (is_super_admin());

-- =====================================================================
-- clients
-- =====================================================================
alter table clients enable row level security;

create policy clients_select on clients for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and id = current_client_id())
);

create policy clients_insert on clients for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy clients_update on clients for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

-- Only ca/super_admin can deactivate/delete client records (spec gives
-- staff view/manage-assigned rights, not delete rights).
create policy clients_delete on clients for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
);

-- =====================================================================
-- tasks
-- =====================================================================
alter table tasks enable row level security;

-- Staff are restricted to tasks assigned to them (per Task 2 spec: the
-- assigned_to = auth-linked-profile rule applies specifically to tasks).
create policy tasks_select on tasks for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
  or (firm_id = current_firm_id() and current_role() = 'staff' and assigned_to = current_profile_id())
  or (current_role() = 'client' and client_id = current_client_id())
);

create policy tasks_insert on tasks for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy tasks_update on tasks for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
  or (firm_id = current_firm_id() and current_role() = 'staff' and assigned_to = current_profile_id())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
  or (firm_id = current_firm_id() and current_role() = 'staff' and assigned_to = current_profile_id())
);

create policy tasks_delete on tasks for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
);

-- =====================================================================
-- documents
-- =====================================================================
alter table documents enable row level security;

-- Per Task 2 spec note: "staff should see all clients/documents within
-- their firm unless told otherwise" — so documents are firm-wide for
-- ca/staff, unlike tasks.
create policy documents_select on documents for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id())
);

create policy documents_insert on documents for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id())
);

create policy documents_update on documents for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id() and uploaded_by = current_profile_id())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id() and uploaded_by = current_profile_id())
);

create policy documents_delete on documents for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

-- =====================================================================
-- invoices
-- =====================================================================
alter table invoices enable row level security;

create policy invoices_select on invoices for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id())
);

create policy invoices_insert on invoices for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy invoices_update on invoices for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy invoices_delete on invoices for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
);

-- =====================================================================
-- invoice_items (no firm_id column — join via invoices)
-- =====================================================================
alter table invoice_items enable row level security;

create policy invoice_items_select on invoice_items for select
using (
  is_super_admin()
  or exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id
      and (
        (is_firm_staff_or_owner() and i.firm_id = current_firm_id())
        or (current_role() = 'client' and i.client_id = current_client_id())
      )
  )
);

create policy invoice_items_insert on invoice_items for insert
with check (
  is_super_admin()
  or exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id
      and is_firm_staff_or_owner()
      and i.firm_id = current_firm_id()
  )
);

create policy invoice_items_update on invoice_items for update
using (
  is_super_admin()
  or exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id
      and is_firm_staff_or_owner()
      and i.firm_id = current_firm_id()
  )
)
with check (
  is_super_admin()
  or exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id
      and is_firm_staff_or_owner()
      and i.firm_id = current_firm_id()
  )
);

create policy invoice_items_delete on invoice_items for delete
using (
  is_super_admin()
  or exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id
      and is_firm_staff_or_owner()
      and i.firm_id = current_firm_id()
  )
);

-- =====================================================================
-- payments
-- =====================================================================
alter table payments enable row level security;

create policy payments_select on payments for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id())
);

-- Client role is view-only for payments per spec — no insert/update
-- policy grants them any write access.
create policy payments_insert on payments for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy payments_update on payments for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy payments_delete on payments for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and current_role() = 'ca')
);

-- =====================================================================
-- deadlines
-- =====================================================================
alter table deadlines enable row level security;

create policy deadlines_select on deadlines for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
  or (current_role() = 'client' and client_id = current_client_id())
);

create policy deadlines_insert on deadlines for insert
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy deadlines_update on deadlines for update
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
)
with check (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

create policy deadlines_delete on deadlines for delete
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

-- =====================================================================
-- notifications (recipient-scoped via user_id -> profiles.id)
-- =====================================================================
alter table notifications enable row level security;

create policy notifications_select on notifications for select
using (
  is_super_admin()
  or user_id = current_profile_id()
);

-- ca/staff can create notifications for anyone in their own firm
-- (e.g. "task assigned" notices); any user can also create a
-- notification for themselves (e.g. client-side deadline reminders).
create policy notifications_insert on notifications for insert
with check (
  is_super_admin()
  or user_id = current_profile_id()
  or (
    is_firm_staff_or_owner()
    and exists (
      select 1 from profiles p
      where p.id = notifications.user_id
        and p.firm_id = current_firm_id()
    )
  )
);

create policy notifications_update on notifications for update
using (
  is_super_admin()
  or user_id = current_profile_id()
)
with check (
  is_super_admin()
  or user_id = current_profile_id()
);

create policy notifications_delete on notifications for delete
using (
  is_super_admin()
  or user_id = current_profile_id()
);

-- =====================================================================
-- activity_logs (append-only audit trail)
-- =====================================================================
alter table activity_logs enable row level security;

-- Clients are not listed as having activity_logs visibility in the
-- spec's role list — restricted to ca/staff/super_admin.
create policy activity_logs_select on activity_logs for select
using (
  is_super_admin()
  or (firm_id = current_firm_id() and is_firm_staff_or_owner())
);

-- Any authenticated user (including clients) can write their own
-- action to the log; the app is expected to set user_id/firm_id
-- correctly when logging.
create policy activity_logs_insert on activity_logs for insert
with check (
  is_super_admin()
  or user_id = current_profile_id()
);

-- Logs are treated as immutable — no update policy is created, so
-- update is denied by default once RLS is enabled.

create policy activity_logs_delete on activity_logs for delete
using (is_super_admin());
