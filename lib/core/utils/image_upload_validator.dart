import '../errors/app_failure.dart';

/// Validates image uploads (profile pictures, firm logos) before they're
/// sent to Supabase Storage. Keep this separate from the document-upload
/// validator that Task 7 will add for client-documents (different allowed
/// types: pdf/doc/xls/etc, likely a larger size limit).
class ImageUploadValidator {
  ImageUploadValidator._();

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  /// 5MB, per the spec's "reasonable max" guidance for profile/logo images.
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Throws [AppFailure] with a friendly message if the file fails
  /// validation. Call before uploading.
  static void validate({required String fileName, required int sizeBytes}) {
    final ext = _extensionOf(fileName);

    if (ext == null || !allowedExtensions.contains(ext)) {
      throw const AppFailure(
        'Please choose a JPG or PNG image.',
      );
    }

    if (sizeBytes <= 0) {
      throw const AppFailure('That file appears to be empty. Please choose another.');
    }

    if (sizeBytes > maxSizeBytes) {
      throw const AppFailure('Image is too large. Please choose a file under 5MB.');
    }
  }

  static String? _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return null;
    return fileName.substring(dot + 1).toLowerCase();
  }
}
