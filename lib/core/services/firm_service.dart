import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/firm.dart';
import '../errors/app_failure.dart';
import '../utils/image_upload_validator.dart';
import 'profile_service.dart';
import 'supabase_service.dart';

/// All reads/writes to `firms` and firm-logo storage go through here.
/// RLS restricts firm updates to `ca` role / same firm (see
/// 0003_rls.sql `firms_update`); this service also enforces the same
/// rule client-side so the UI fails fast with a friendly message rather
/// than a raw 403 from Postgres.
class FirmService {
  FirmService._();
  static final FirmService instance = FirmService._();

  static const _bucket = 'profile-images';
  static const _signedUrlExpirySeconds = 3600;

  SupabaseClient get _db => SupabaseService.client;

  // ---------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------

  /// Fetches the current user's firm. Returns null if the user has no
  /// firm yet (e.g. a super_admin, or a ca account created before a firm
  /// was assigned).
  Future<Firm?> getCurrentFirm() async {
    final profile = await ProfileService.instance.getCurrentProfile();
    final firmId = profile.firmId;
    if (firmId == null) return null;

    try {
      final row = await _db.from('firms').select().eq('id', firmId).maybeSingle();
      if (row == null) return null;
      return Firm.fromMap(row);
    } on PostgrestException {
      throw const AppFailure('Unable to load firm details. Please try again.');
    }
  }

  // ---------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------

  /// Updates firm details. Caller (UI) must already have confirmed the
  /// current user's role is `ca` or `super_admin` — this is enforced
  /// again here as a client-side guard, and independently by RLS.
  Future<Firm> updateFirm({
    required String firmId,
    String? firmName,
    String? registrationNumber,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    final updates = Firm.buildUpdateMap(
      firmName: firmName,
      registrationNumber: registrationNumber,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
    );

    if (updates.isEmpty) {
      final row = await _db.from('firms').select().eq('id', firmId).single();
      return Firm.fromMap(row);
    }

    try {
      final row = await _db
          .from('firms')
          .update(updates)
          .eq('id', firmId)
          .select()
          .single();
      return Firm.fromMap(row);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.message.toLowerCase().contains('permission')) {
        throw const AppFailure("You don't have permission to update firm details.");
      }
      throw const AppFailure('Unable to update firm details. Please try again.');
    }
  }

  // ---------------------------------------------------------------------
  // Logo
  // ---------------------------------------------------------------------

  Future<Firm> uploadFirmLogo({
    required String firmId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    ImageUploadValidator.validate(fileName: fileName, sizeBytes: bytes.length);

    final ext = fileName.split('.').last.toLowerCase();
    final path = 'firms/$firmId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      onProgress?.call(0.0);
      await _db.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
              upsert: true,
            ),
          );
      onProgress?.call(1.0);
    } on StorageException {
      throw const AppFailure('Logo upload failed. Please try again.');
    }

    try {
      final row = await _db
          .from('firms')
          .update({'logo_url': path})
          .eq('id', firmId)
          .select()
          .single();
      return Firm.fromMap(row);
    } on PostgrestException {
      throw const AppFailure(
        'Logo uploaded, but we could not save it to your firm. Please try again.',
      );
    }
  }

  Future<String?> getLogoSignedUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      return await _db.storage.from(_bucket).createSignedUrl(path, _signedUrlExpirySeconds);
    } on StorageException {
      return null;
    }
  }
}
