import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_service.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/clients/clients_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/invoices/invoices_screen.dart';
import '../../features/profile/firm_settings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../services/supabase_service.dart';
import '../widgets/app_layout.dart';
import '../widgets/coming_soon_screen.dart';
import '../widgets/not_found_screen.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

/// Single source of truth for app navigation.
///
/// Screens are decoupled from each other here: a screen calls
/// `context.go(AppRoutes.dashboard)` and never has to import
/// `DashboardPlaceholderScreen` directly. All auth-gating that used to be
/// scattered across individual `Navigator.push` calls is centralized in
/// [_redirect] below.
///
/// PLACEHOLDER NOTE — read before touching /create-firm or /firm-pending:
/// The audit/handoff notes for this project describe a self-service
/// "create firm → pending approval" flow (CreateFirmScreen,
/// FirmPendingScreen, PostAuthGate, a `firm_id`-aware redirect). None of
/// those files exist in the codebase that was provided for this task —
/// only auth, profile, firm-settings, and the dashboard placeholder do.
/// Rather than invent that business logic (fake tenant state, a fake
/// approval flow, etc.), this router:
///   1. Reserves the /create-firm and /firm-pending paths so the target
///      route table matches what's asked for, and
///   2. Points them at the same no-op `ComingSoonScreen` used for the
///      other unbuilt modules, so nothing 404s.
/// `_redirect` below still only distinguishes "authenticated" vs.
/// "unauthenticated" — exactly the check the app already made via
/// `AuthService.instance.isAuthenticated` before this change. Nothing
/// about who can reach dashboard vs. login has changed. When the real
/// create-firm/pending-approval screens and a firm/tenant status source
/// exist, extend `_redirect` to branch on that status — the shape is
/// ready for it, see the comment inline below.
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(
      AuthService.instance.onAuthStateChange,
    ),
    redirect: _redirect,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      // -----------------------------------------------------------------
      // Auth flow
      // -----------------------------------------------------------------
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // -----------------------------------------------------------------
      // Authenticated Shell
      // -----------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          // -----------------------------------------------------------------
          // Profile / firm
          // -----------------------------------------------------------------
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.firmSettings,
            builder: (context, state) => const FirmSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.subscription,
            builder: (context, state) => const SubscriptionScreen(),
          ),
    
          // -----------------------------------------------------------------
          // Organization onboarding — reserved, see PLACEHOLDER NOTE above
          // -----------------------------------------------------------------
          GoRoute(
            path: AppRoutes.createFirm,
            builder: (context, state) => const ComingSoonScreen(
              title: 'Create Firm',
              icon: Icons.apartment_rounded,
              subtitle:
                  'Self-service firm creation isn\'t in this codebase yet — '
                  'route reserved for when it is built.',
            ),
          ),
          GoRoute(
            path: AppRoutes.firmPending,
            builder: (context, state) => const ComingSoonScreen(
              title: 'Firm Approval Pending',
              icon: Icons.hourglass_top_rounded,
              subtitle:
                  'The pending-approval screen isn\'t in this codebase yet — '
                  'route reserved for when it is built.',
            ),
          ),
    
          // -----------------------------------------------------------------
          // Dashboard
          // -----------------------------------------------------------------
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
    
          // -----------------------------------------------------------------
          // Real business modules
          // -----------------------------------------------------------------
          GoRoute(
            path: AppRoutes.clients,
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: AppRoutes.documents,
            builder: (context, state) => const ComingSoonScreen(title: 'Documents', icon: Icons.description_rounded),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: AppRoutes.billing,
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: AppRoutes.workflows,
            builder: (context, state) => const ComingSoonScreen(title: 'Workflows', icon: Icons.account_tree_rounded),
          ),
          GoRoute(
            path: AppRoutes.compliance,
            builder: (context, state) => const ComingSoonScreen(title: 'Compliance', icon: Icons.gavel_rounded),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const ComingSoonScreen(title: 'Notifications', icon: Icons.notifications_rounded),
          ),
          GoRoute(
            path: AppRoutes.communication,
            builder: (context, state) => const ComingSoonScreen(title: 'Communication', icon: Icons.chat_bubble_rounded),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ComingSoonScreen(title: 'Reports', icon: Icons.bar_chart_rounded),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const ComingSoonScreen(title: 'Settings', icon: Icons.settings_rounded),
          ),
          GoRoute(
            path: AppRoutes.admin,
            builder: (context, state) => const ComingSoonScreen(title: 'Admin', icon: Icons.admin_panel_settings_rounded),
          ),
        ],
      ),
    ],
  );

  /// Centralized auth gate. Runs on every navigation *and* whenever
  /// [AuthService.instance.onAuthStateChange] fires (sign in, sign out,
  /// token refresh) via [GoRouterRefreshStream].
  ///
  /// This preserves exactly the access rule the app already had —
  /// authenticated → dashboard, unauthenticated → login — just moved
  /// from being scattered across screens into one place.
  static String? _redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;

    // Splash owns the very first routing decision itself (it runs its
    // intro animation, then explicitly goes to /login or /dashboard).
    // Don't fight it with a redirect while it's on screen.
    if (loc == AppRoutes.splash) return null;

    // Password recovery must stay reachable on its own terms even if a
    // recovery session already makes the user "authenticated" — the
    // screen has its own explicit "done -> Sign In" step. (Previously,
    // main.dart force-navigated to Dashboard on the underlying
    // `userUpdated` auth event, which could yank the user off this
    // screen before they saw the "password updated" confirmation.)
    if (loc == AppRoutes.resetPassword) return null;

    final isAuthenticated =
        SupabaseService.isInitialized && AuthService.instance.isAuthenticated;

    final isAuthScreen = loc == AppRoutes.login ||
        loc == AppRoutes.signup ||
        loc == AppRoutes.forgotPassword;

    if (!isAuthenticated) {
      // Not signed in: only auth screens are reachable.
      return isAuthScreen ? null : AppRoutes.login;
    }

    // Signed in: keep them off the auth screens.
    // NOTE — extension point for real onboarding gating: once a firm/
    // tenant status source exists, branch here on it, e.g.
    //   if (profile.firmId == null) return AppRoutes.createFirm;
    //   if (firm.approvalStatus == 'pending') return AppRoutes.firmPending;
    // before falling through to dashboard. See PLACEHOLDER NOTE above.
    if (isAuthScreen) return AppRoutes.dashboard;

    return null;
  }
}
