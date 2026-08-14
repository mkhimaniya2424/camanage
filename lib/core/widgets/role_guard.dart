import 'package:flutter/material.dart';

import '../../models/profile.dart';

/// Shows [child] only if [role] is one of [allow]. Otherwise shows
/// [fallback] (defaults to nothing — used for hiding nav entries/buttons)
/// or, if [showDeniedMessage] is true, a "You don't have permission"
/// message (used for full-screen guards like Firm Settings, where a
/// blank screen would look broken rather than intentionally hidden).
///
/// This is a pure UI convenience — it never replaces RLS. Every table
/// enforces the real permission check in Postgres regardless of what
/// this widget shows or hides.
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allow,
    required this.child,
    this.fallback,
    this.showDeniedMessage = false,
  });

  final UserRole role;
  final List<UserRole> allow;
  final Widget child;
  final Widget? fallback;
  final bool showDeniedMessage;

  static bool isAllowed(UserRole role, List<UserRole> allow) => allow.contains(role);

  @override
  Widget build(BuildContext context) {
    if (allow.contains(role)) return child;
    if (fallback != null) return fallback!;
    if (showDeniedMessage) return const PermissionDeniedView();
    return const SizedBox.shrink();
  }
}

/// Full-screen "you don't have permission" state — used when a
/// role-restricted screen is reached directly (e.g. deep link, stale
/// nav state) rather than hidden via a nav entry.
class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: Colors.grey[500]),
              const SizedBox(height: 16),
              Text(
                "You don't have permission to access this page.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
