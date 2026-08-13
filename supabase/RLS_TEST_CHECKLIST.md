# RLS Manual Test Checklist (Task 2 / Phase 4)

Run this in the Supabase SQL editor (or via two logged-in app sessions)
**before moving on to Task 4**. All checks assume the seed data from
`seed.sql` plus a second firm/user you create for contrast.

## 0. Setup

1. Run `0001_init.sql`, `0002_auth_trigger.sql`, `0003_rls.sql` in order.
2. Run `seed.sql` to get **Firm A** with a ca/staff/client user.
3. Manually create a **Firm B** with its own ca/staff/client user
   (sign up via the app, or insert directly + set `raw_user_meta_data`
   so the 0002 trigger creates matching profiles).

## 1. Cross-firm isolation (the critical test)

For each of these, log in via the Flutter app (or use `supabase.auth.signIn`
in the SQL editor's "Run as user" / impersonation, or `set local role
authenticated; set local request.jwt.claims = ...` to simulate a JWT) as
a **Firm A ca/staff** user and confirm:

- [ ] `select * from clients` returns **only** Firm A's clients (Firm B's
      client rows must not appear).
- [ ] `select * from tasks` returns only Firm A tasks.
- [ ] `select * from documents` returns only Firm A documents.
- [ ] `select * from invoices` and `invoice_items` return only Firm A data.
- [ ] `select * from payments` returns only Firm A payments.
- [ ] `select * from deadlines` returns only Firm A deadlines.
- [ ] `select * from activity_logs` returns only Firm A logs.
- [ ] `select * from firms` returns only the Firm A row, not Firm B's.
- [ ] Attempting `update clients set name = 'hacked' where firm_id =
      '<firm-b-id>'` affects **0 rows**.
- [ ] Attempting `insert into tasks (firm_id, ...) values ('<firm-b-id>',
      ...)` is rejected (insert `with check` fails).
- [ ] Attempting `delete from documents where firm_id = '<firm-b-id>'`
      affects **0 rows**.

## 2. Role-scoping within the same firm

As a **Firm A staff** user:
- [ ] `select * from tasks` returns only tasks where `assigned_to` is
      this staff member's `profiles.id` — not all of Firm A's tasks.
- [ ] `select * from documents` returns **all** Firm A documents (staff
      has firm-wide document visibility per spec).
- [ ] Cannot `delete from clients` (delete policy is ca/super_admin only).

As a **Firm A client** user (linked via `clients.profile_id`):
- [ ] `select * from clients` returns only their own client row.
- [ ] `select * from tasks` returns only tasks where `client_id` matches
      their own client row.
- [ ] `select * from invoices`/`payments`/`deadlines` returns only their
      own client's rows.
- [ ] Cannot `update tasks set status = 'completed'` on their own task
      (clients have no task-update policy — should affect 0 rows).
- [ ] Cannot `insert into payments (...)` (client has no payments-insert
      policy).
- [ ] `select * from activity_logs` returns **0 rows** (clients have no
      select policy on this table).

## 3. Super admin

As a **super_admin** user:
- [ ] Can `select` across all tables regardless of `firm_id` (Firm A and
      Firm B rows both appear).
- [ ] Can `insert into firms` (only super_admin has this policy).

## 4. Anonymous / unauthenticated

- [ ] Using the `anon` key with no session, all `select` queries against
      business tables return **0 rows** (no policy grants `anon` access;
      only `authenticated` role functions are used above).

## 5. Sanity check on helper functions

- [ ] `select public.current_firm_id();` while impersonating a Firm A
      user returns Firm A's `firms.id`, not null and not Firm B's id.
- [ ] `select public.is_super_admin();` returns `false` for a non-admin
      user and `true` for the super_admin user.

---

If any check fails, do not proceed to Task 4 — fix the failing policy in
`0003_rls.sql`, redeploy, and re-run the checklist.
