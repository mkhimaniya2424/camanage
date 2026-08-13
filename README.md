# CA Desk — Project Setup

This is step 1 only: project scaffolding + Supabase connection. No feature
screens are implemented yet.

## What's here

```
lib/
  main.dart                      # loads .env, initializes Supabase, shows a Connected/Failed check
  core/
    config/env_config.dart       # typed getters for SUPABASE_URL / SUPABASE_ANON_KEY
    services/supabase_service.dart  # Supabase.initialize() wrapper + shared client
  models/                        # (empty, for Phase 3 — DB models)
  features/
    auth/ dashboard/ clients/ tasks/ documents/ invoices/
    payments/ deadlines/ notifications/ profile/   # (empty, one per module)
.env                              # your local Supabase URL + anon key (gitignored)
.env.example                      # blank template, safe to commit
```

## Setup

1. `flutter pub get`
2. Copy your Supabase project values into `.env`:
   ```
   SUPABASE_URL=https://xxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJ...
   ```
   Use the **anon/public** key only — never the service-role key.
3. `flutter run`

On startup you'll see a screen that says **"Supabase Connected"** (teal cloud
icon) if `Supabase.initialize()` succeeded, or **"Supabase Connection
Failed"** with the error message if it didn't (e.g. placeholder values still
in `.env`, or bad URL/key). The same status is also printed to the console.

## Note on verification

This was scaffolded in a sandboxed environment without the Flutter SDK or
access to pub.dev, so I wasn't able to run `flutter pub get` / `flutter run`
myself to confirm the build. The code follows the standard supabase_flutter
+ flutter_dotenv init pattern, but please run step 1–3 above on your machine
and let me know if anything errors — happy to fix immediately.

## Notes

- `.env` is listed in `pubspec.yaml` assets so `flutter_dotenv` can load it
  at runtime, and is gitignored so it never gets committed.
- Only the anon key ever goes into the app. Nothing in `lib/` reads a
  service-role key or any other secret.
- Folder structure matches the phased plan (Phase 1 here); `models/` and the
  per-module folders under `features/` are intentionally empty placeholders
  for the next phases.

---

## Phase 2 — Authentication (added)

New files:

```
lib/models/profile.dart              # Profile model + UserRole enum
lib/features/auth/auth_service.dart  # AuthService — all Supabase Auth calls go through here
```

**Before this works, run the schema migrations below** (they include the
auth trigger this service depends on). It creates a Postgres trigger that
auto-inserts a `profiles` row whenever someone signs up — reading
`full_name` / `phone` / `role` / `firm_id` out of the signup metadata
`AuthService.signUp()` sends. This sidesteps a real Supabase gotcha: if
email confirmation is on, there's no active session right after
`signUp()`, so the Flutter app can't insert into `profiles` itself yet
(RLS has nothing to check `auth.uid()` against). The trigger runs as
`security definer`, so it works regardless of confirmation timing.

`AuthService` covers:

- `signUp()` — email/password + role/name/phone/firmId as metadata
- `signIn()` / `signOut()`
- `sendPasswordResetEmail()` / `resetPassword()` (forgot + reset flow)
- `changePassword()` (already signed in)
- `resendEmailVerification()` / `isEmailVerified`
- `fetchCurrentProfile()` — pulls the matching `profiles` row
- `onAuthStateChange` — stream to drive Splash → Login/Dashboard routing
- All Supabase `AuthException`s are mapped to friendly messages
  (`AuthFailure`) — no raw Supabase error text ever needs to reach the UI

No login/signup **screens** yet — per your instructions this phase is
service-layer only. `main.dart` now also prints whether a session was
found on startup, just to confirm the wiring works end to end.

---

## Phase 3 — Database Schema (added)

New files:

```
supabase/migrations/0001_init.sql          # all business tables, enums, indexes
supabase/migrations/0002_auth_trigger.sql  # auto-creates profiles on signup (AuthService depends on this)
supabase/seed.sql                          # local test data — see note inside the file
```

### How to run these against your Supabase project

1. Open your Supabase project → **SQL Editor**.
2. Paste and run `0001_init.sql` first. It creates: `firms`, `profiles`,
   `clients`, `tasks`, `documents`, `invoices`, `invoice_items`, `payments`,
   `deadlines`, `notifications`, `activity_logs`, all enums, indexes, and an
   `updated_at` trigger shared by every table that has one.
3. Run `0002_auth_trigger.sql` next. This is the trigger `AuthService`
   already assumes exists — without it, `signUp()` will succeed in Auth but
   the app won't find a matching `profiles` row afterward.
4. **RLS is intentionally not enabled yet** — every table is currently
   readable/writable by any authenticated (or even anon, depending on your
   project's default grants) request. Do not point the real app at this
   project until the RLS migration (next task) is applied. This is fine for
   schema review in the SQL Editor, not fine for testing through the app
   with real accounts.
5. (Optional, local/CLI dev only) `supabase/seed.sql` adds one test firm,
   a CA owner, a staff member, and a client with a linked profile. Read the
   note at the top of that file first — it assumes `auth.users` rows already
   exist for those ids, which only works with the Supabase CLI's local
   Postgres, not the hosted dashboard's SQL Editor (you can't insert into
   `auth.users` there directly). On hosted Supabase, sign up real test
   accounts through the app instead and let the trigger create their
   profiles.

### Notes

- `clients` has a nullable `profile_id` (added via `alter table` after the
  base column list, so the original field order from the spec stays intact)
  linking a client's business record to their login account — this is what
  lets RLS later say "a client can see their own data."
- `invoices` has a `unique (firm_id, invoice_number)` constraint — not in
  the original field list, but invoice numbers should be unique per firm,
  not globally, so I added it. Flag it if you want it removed.
- I wasn't able to run these against a live Supabase project from this
  sandbox (no network access) — please run them in your SQL Editor and let
  me know if anything errors.

**Update:** as of your live project, this schema + RLS + storage policies
are already applied and working — confirmed via SQL Editor query results.
No need to re-run 0001/0002/seed against that project.

---

## Phase 3.5 — Auth Screens (added)

New files:

```
lib/features/auth/splash_screen.dart              # session check -> Login or Dashboard
lib/features/auth/login_screen.dart                # email/password sign-in
lib/features/auth/forgot_password_screen.dart      # sends reset email
lib/features/auth/reset_password_screen.dart       # sets new password (after reset link)
lib/features/dashboard/dashboard_placeholder_screen.dart  # temporary post-login screen
```

`main.dart` now launches into `SplashScreen` instead of the old
connection-check screen (that check still runs — if Supabase fails to
initialize you'll see the same error screen as before, just as a fallback
rather than the default).

Flow: **Splash → (session found) → Dashboard placeholder** or
**Splash → (no session) → Login → Dashboard placeholder**. From Login you
can reach Forgot Password; from there a reset email is sent. The
`ResetPasswordScreen` isn't wired into a route yet because it depends on
deep-link handling (opening the app from the emailed link) — that's a
platform-specific piece (Android intent filters / iOS universal links)
outside pure Dart, worth doing as its own step once you're testing on a
real device.

All screens go through `AuthService` only — no widget touches
`Supabase.instance.client` directly. Errors are shown via
`AuthFailure.message` (the friendly mapped text), never raw Supabase
exceptions.

The dashboard placeholder shows the signed-in user's email and role
(pulled via `fetchCurrentProfile()`) and a sign-out button — enough to
confirm the whole auth loop works end-to-end. It gets replaced by the real
dashboard later in the plan.

I wasn't able to run `flutter run` in this sandbox — please test on your
machine and let me know if anything doesn't compile or behave as expected.
#   c a m a n a g e  
 