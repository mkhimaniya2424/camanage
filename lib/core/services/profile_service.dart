import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import '../errors/app_failure.dart';
import '../utils/image_upload_validator.dart';
import 'supabase_service.dart';

/// All reads/writes to `profiles` (other than sign-up, which lives in
/// AuthService) and profile-image storage go through here. Widgets never
/// call Supabase directly.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const _bucket = 'profile-images';
  static const _signedUrlExpirySeconds = 3600; // 1 hour

  SupabaseClient get _db => SupabaseService.client;

  // ---------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------

  /// Current user's own profile row. Throws [AppFailure] if not signed in
  /// or the row can't be loaded.
  Future<Profile> getCurrentProfile() async {
    final authUserId = _db.auth.currentUser?.id;
    if (authUserId == null) {
      throw const AppFailure('Your session has expired. Please sign in again.');
    }

    try {
      final row = await _db
          .from('profiles')
          .select()
          .eq('auth_user_id', authUserId)
          .single();
      return Profile.fromMap(row);
    } on PostgrestException {
      throw const AppFailure('Unable to load your profile. Please try again.');
    }
  }

  // ---------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------

  /// Updates editable profile fields for the current user. Email/role/
  /// firm are not editable here — RLS also blocks a self-update of
  /// `role`/`firm_id` implicitly by design (only ca_owner/super_admin
  /// policies allow firm-wide profile updates; a plain "update own row"
  /// caller can still only change what the UI exposes here).
  Future<Profile> updateProfile({String? fullName, String? phone}) async {
    final authUserId = _db.auth.currentUser?.id;
    if (authUserId == null) {
      throw const AppFailure('Your session has expired. Please sign in again.');
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;

    if (updates.isEmpty) {
      return getCurrentProfile();
    }

    try {
      final row = await _db
          .from('profiles')
          .update(updates)
          .eq('auth_user_id', authUserId)
          .select()
          .single();
      return Profile.fromMap(row);
    } on PostgrestException {
      throw const AppFailure('Unable to update your profile. Please try again.');
    }
  }

  // ---------------------------------------------------------------------
  // Profile image
  // ---------------------------------------------------------------------

  /// Uploads/replaces the current user's profile picture and updates
  /// `profiles.profile_image` with the storage path (not a public URL —
  /// this bucket is private; resolve to a viewable URL on demand via
  /// [getProfileImageSignedUrl]).
  ///
  /// [onProgress] receives a 0.0–1.0 value. Supabase's storage upload
  /// doesn't currently expose byte-level progress for `uploadBinary`, so
  /// this reports 0.0 (start) and 1.0 (done) — swap for a chunked upload
  /// with a real progress stream later if fine-grained progress matters.
  Future<Profile> uploadProfileImage({
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final profile = await getCurrentProfile();

    ImageUploadValidator.validate(fileName: fileName, sizeBytes: bytes.length);

    final ext = fileName.split('.').last.toLowerCase();
    final path = 'avatars/${profile.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      onProgress?.call(0.0);
      await _db.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentTypeFor(ext),
              upsert: true,
            ),
          );
      onProgress?.call(1.0);
    } on StorageException {
      throw const AppFailure('Image upload failed. Please try again.');
    }

    try {
      final row = await _db
          .from('profiles')
          .update({'profile_image': path})
          .eq('id', profile.id)
          .select()
          .single();
      return Profile.fromMap(row);
    } on PostgrestException {
      throw const AppFailure(
        'Image uploaded, but we could not save it to your profile. Please try again.',
      );
    }
  }

  /// Resolves a stored profile-image path to a short-lived signed URL for
  /// display. Returns null if [path] is null/empty (no image set).
  Future<String?> getProfileImageSignedUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      return await _db.storage.from(_bucket).createSignedUrl(path, _signedUrlExpirySeconds);
    } on StorageException {
      return null;
    }
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
