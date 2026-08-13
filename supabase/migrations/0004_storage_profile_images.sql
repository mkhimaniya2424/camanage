-- =====================================================================
-- CA Desk — profile-images Storage Bucket & Policies (Task 4 / Phase 5)
-- =====================================================================
-- Run after 0003_rls.sql (reuses its helper functions: current_profile_id,
-- current_firm_id, current_role, is_super_admin, is_firm_staff_or_owner).
--
-- Path convention inside the `profile-images` bucket:
--   avatars/{profile_id}/{filename}   -- user profile pictures
--   firms/{firm_id}/{filename}        -- firm logos
--
-- The bucket is PRIVATE. The app never constructs a permanent public
-- URL — ProfileService/FirmService generate short-lived signed URLs on
-- demand (see lib/core/services/profile_service.dart,
-- lib/core/services/firm_service.dart).
-- =====================================================================

insert into storage.buckets (id, name, public)
values ('profile-images', 'profile-images', false)
on conflict (id) do nothing;

-- storage.objects already has RLS enabled by default in Supabase.

-- ---------------------------------------------------------------------
-- SELECT (view/download via signed URL)
-- ---------------------------------------------------------------------
create policy "profile_images_select" on storage.objects for select
using (
  bucket_id = 'profile-images'
  and (
    is_super_admin()
    -- own avatar
    or (
      (storage.foldername(name))[1] = 'avatars'
      and (storage.foldername(name))[2] = current_profile_id()::text
    )
    -- ca/staff can view avatars of anyone in their own firm (staff directory, etc.)
    or (
      (storage.foldername(name))[1] = 'avatars'
      and is_firm_staff_or_owner()
      and exists (
        select 1 from profiles p
        where p.id::text = (storage.foldername(name))[2]
          and p.firm_id = current_firm_id()
      )
    )
    -- any member of a firm can view that firm's logo
    or (
      (storage.foldername(name))[1] = 'firms'
      and (storage.foldername(name))[2] = current_firm_id()::text
    )
  )
);

-- ---------------------------------------------------------------------
-- INSERT (upload)
-- ---------------------------------------------------------------------
create policy "profile_images_insert" on storage.objects for insert
with check (
  bucket_id = 'profile-images'
  and (
    is_super_admin()
    -- users may only upload to their own avatar folder
    or (
      (storage.foldername(name))[1] = 'avatars'
      and (storage.foldername(name))[2] = current_profile_id()::text
    )
    -- only the firm's ca (owner) may upload/replace the firm logo
    or (
      (storage.foldername(name))[1] = 'firms'
      and (storage.foldername(name))[2] = current_firm_id()::text
      and current_role() = 'ca'
    )
  )
);

-- ---------------------------------------------------------------------
-- UPDATE (replace — relevant if a client ever overwrites in place;
-- app currently uploads new filenames with upsert:true, so this mainly
-- covers that upsert path)
-- ---------------------------------------------------------------------
create policy "profile_images_update" on storage.objects for update
using (
  bucket_id = 'profile-images'
  and (
    is_super_admin()
    or (
      (storage.foldername(name))[1] = 'avatars'
      and (storage.foldername(name))[2] = current_profile_id()::text
    )
    or (
      (storage.foldername(name))[1] = 'firms'
      and (storage.foldername(name))[2] = current_firm_id()::text
      and current_role() = 'ca'
    )
  )
)
with check (
  bucket_id = 'profile-images'
  and (
    is_super_admin()
    or (
      (storage.foldername(name))[1] = 'avatars'
      and (storage.foldername(name))[2] = current_profile_id()::text
    )
    or (
      (storage.foldername(name))[1] = 'firms'
      and (storage.foldername(name))[2] = current_firm_id()::text
      and current_role() = 'ca'
    )
  )
);

-- ---------------------------------------------------------------------
-- DELETE
-- ---------------------------------------------------------------------
create policy "profile_images_delete" on storage.objects for delete
using (
  bucket_id = 'profile-images'
  and (
    is_super_admin()
    or (
      (storage.foldername(name))[1] = 'avatars'
      and (storage.foldername(name))[2] = current_profile_id()::text
    )
    or (
      (storage.foldername(name))[1] = 'firms'
      and (storage.foldername(name))[2] = current_firm_id()::text
      and current_role() = 'ca'
    )
  )
);
