/// Generic, UI-safe failure used by non-auth services (Profile, Firm, and
/// later Client/Task/Document/etc). Mirrors the pattern already used by
/// `AuthFailure` in auth_service.dart.
///
/// NOTE: Task 15 (Offline Handling & Error Standardization) will introduce
/// a single AppException/ErrorMapper that every service — including
/// AuthService — routes through. This class is the shared foundation for
/// that; new services should throw `AppFailure` (not ad-hoc strings) so
/// that later consolidation is a mechanical refactor rather than a rewrite.
class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
