/// Centralized route paths for the whole app.
///
/// Every screen navigation should go through one of these constants via
/// `context.go(...)` / `context.push(...)` — never a raw string literal,
/// and never `Navigator.push(MaterialPageRoute(...))` for top-level
/// screens. This is the single source of truth for "what routes exist"
/// and keeps screens decoupled from each other (a screen no longer needs
/// to import another screen's widget just to navigate to it).
abstract final class AppRoutes {
  // ---------------------------------------------------------------------
  // Auth flow (implemented)
  // ---------------------------------------------------------------------
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // ---------------------------------------------------------------------
  // Profile / firm (implemented)
  // ---------------------------------------------------------------------
  static const profile = '/profile';
  static const firmSettings = '/firm-settings';
  static const subscription = '/subscription';

  // ---------------------------------------------------------------------
  // Organization onboarding (route reserved — screens not yet in this
  // codebase, see PLACEHOLDER note in app_router.dart)
  // ---------------------------------------------------------------------
  static const createFirm = '/create-firm';
  static const firmPending = '/firm-pending';

  // ---------------------------------------------------------------------
  // Dashboard (implemented — currently a placeholder screen)
  // ---------------------------------------------------------------------
  static const dashboard = '/dashboard';

  // ---------------------------------------------------------------------
  // Future business modules (route reserved, screens not implemented)
  // ---------------------------------------------------------------------
  static const clients = '/clients';
  static const documents = '/documents';
  static const tasks = '/tasks';
  static const workflows = '/workflows';
  static const compliance = '/compliance';
  static const notifications = '/notifications';
  static const communication = '/communication';
  static const billing = '/billing';
  static const reports = '/reports';
  static const settings = '/settings';
  static const admin = '/admin';
}
