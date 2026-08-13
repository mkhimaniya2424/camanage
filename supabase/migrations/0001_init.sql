-- =====================================================================
-- CA Desk — Core Schema (Task 1 / Phase 3)
-- =====================================================================
-- Creates all business tables with firm_id-based multi-tenant columns,
-- enums, indexes, and an updated_at trigger.
-- RLS is NOT enabled here — see 0003_rls.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------
create extension if not exists "pgcrypto"; -- gen_random_uuid()

-- ---------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------
create type user_role as enum ('super_admin', 'ca', 'staff', 'client');

create type task_priority as enum ('low', 'medium', 'high', 'urgent');
create type task_status as enum ('pending', 'in_progress', 'completed', 'overdue');

create type document_category as enum (
  'income_tax', 'gst', 'audit', 'roc', 'invoice', 'bank', 'other'
);

create type invoice_status as enum (
  'draft', 'sent', 'paid', 'pending', 'overdue', 'cancelled'
);

create type deadline_category as enum (
  'GST', 'Income Tax', 'TDS', 'Audit', 'ROC', 'Other'
);

create type payment_status as enum ('pending', 'completed', 'failed', 'refunded');

-- ---------------------------------------------------------------------
-- Helper: shared updated_at trigger function
-- ---------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- firms
-- ---------------------------------------------------------------------
create table firms (
  id uuid primary key default gen_random_uuid(),
  firm_name text not null,
  registration_number text,
  email text,
  phone text,
  address text,
  city text,
  state text,
  pincode text,
  logo_url text,
  subscription_plan text default 'free',
  subscription_status text default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_firms_updated_at
  before update on firms
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------
create table profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  profile_image text,
  role user_role not null default 'client',
  firm_id uuid references firms(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_profiles_firm_id on profiles(firm_id);
create index idx_profiles_auth_user_id on profiles(auth_user_id);

create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- clients
-- ---------------------------------------------------------------------
create table clients (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  name text not null,
  client_type text,
  email text,
  phone text,
  address text,
  pan_number text,
  gstin text,
  tan_number text,
  date_of_birth date,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_clients_firm_id on clients(firm_id);
create index idx_clients_status on clients(status);
create index idx_clients_pan_number on clients(pan_number);
create index idx_clients_gstin on clients(gstin);

create trigger trg_clients_updated_at
  before update on clients
  for each row execute function set_updated_at();

-- Link a client business record to the auth account that logs in as
-- that client (nullable — a client row can exist before the client
-- has a login, e.g. added by staff first).
alter table clients
  add column profile_id uuid references profiles(id) on delete set null;

create index idx_clients_profile_id on clients(profile_id);

-- ---------------------------------------------------------------------
-- tasks
-- ---------------------------------------------------------------------
create table tasks (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  client_id uuid references clients(id) on delete cascade,
  assigned_to uuid references profiles(id) on delete set null,
  title text not null,
  description text,
  priority task_priority not null default 'medium',
  status task_status not null default 'pending',
  due_date date,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_tasks_firm_id on tasks(firm_id);
create index idx_tasks_client_id on tasks(client_id);
create index idx_tasks_assigned_to on tasks(assigned_to);
create index idx_tasks_status on tasks(status);
create index idx_tasks_due_date on tasks(due_date);

create trigger trg_tasks_updated_at
  before update on tasks
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- documents
-- ---------------------------------------------------------------------
create table documents (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  client_id uuid references clients(id) on delete cascade,
  uploaded_by uuid references profiles(id) on delete set null,
  file_name text not null,
  file_path text not null,
  file_type text,
  file_size bigint,
  category document_category not null default 'other',
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_documents_firm_id on documents(firm_id);
create index idx_documents_client_id on documents(client_id);
create index idx_documents_category on documents(category);

create trigger trg_documents_updated_at
  before update on documents
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- invoices
-- ---------------------------------------------------------------------
create table invoices (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  client_id uuid not null references clients(id) on delete cascade,
  invoice_number text not null,
  invoice_date date not null default current_date,
  due_date date,
  subtotal numeric(12,2) not null default 0,
  tax numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  status invoice_status not null default 'draft',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (firm_id, invoice_number)
);

create index idx_invoices_firm_id on invoices(firm_id);
create index idx_invoices_client_id on invoices(client_id);
create index idx_invoices_status on invoices(status);
create index idx_invoices_invoice_date on invoices(invoice_date);
create index idx_invoices_due_date on invoices(due_date);

create trigger trg_invoices_updated_at
  before update on invoices
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- invoice_items
-- ---------------------------------------------------------------------
create table invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices(id) on delete cascade,
  description text not null,
  quantity numeric(12,2) not null default 1,
  rate numeric(12,2) not null default 0,
  tax numeric(12,2) not null default 0,
  amount numeric(12,2) not null default 0
);

create index idx_invoice_items_invoice_id on invoice_items(invoice_id);

-- ---------------------------------------------------------------------
-- payments
-- ---------------------------------------------------------------------
create table payments (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  invoice_id uuid references invoices(id) on delete set null,
  client_id uuid references clients(id) on delete set null,
  amount numeric(12,2) not null,
  payment_method text,
  transaction_id text,
  payment_date date not null default current_date,
  status payment_status not null default 'completed',
  created_at timestamptz not null default now()
);

create index idx_payments_firm_id on payments(firm_id);
create index idx_payments_invoice_id on payments(invoice_id);
create index idx_payments_client_id on payments(client_id);
create index idx_payments_payment_date on payments(payment_date);

-- ---------------------------------------------------------------------
-- deadlines
-- ---------------------------------------------------------------------
create table deadlines (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid not null references firms(id) on delete cascade,
  client_id uuid references clients(id) on delete cascade,
  title text not null,
  description text,
  deadline_date date not null,
  category deadline_category not null default 'Other',
  status text not null default 'upcoming',
  created_at timestamptz not null default now()
);

create index idx_deadlines_firm_id on deadlines(firm_id);
create index idx_deadlines_client_id on deadlines(client_id);
create index idx_deadlines_deadline_date on deadlines(deadline_date);
create index idx_deadlines_status on deadlines(status);

-- ---------------------------------------------------------------------
-- notifications
-- ---------------------------------------------------------------------
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  message text,
  type text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_notifications_user_id on notifications(user_id);
create index idx_notifications_is_read on notifications(is_read);

-- ---------------------------------------------------------------------
-- activity_logs
-- ---------------------------------------------------------------------
create table activity_logs (
  id uuid primary key default gen_random_uuid(),
  firm_id uuid references firms(id) on delete cascade,
  user_id uuid references profiles(id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  description text,
  created_at timestamptz not null default now()
);

create index idx_activity_logs_firm_id on activity_logs(firm_id);
create index idx_activity_logs_user_id on activity_logs(user_id);
create index idx_activity_logs_created_at on activity_logs(created_at desc);
