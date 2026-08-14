import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../router/app_routes.dart';
import 'app_widgets.dart';

/// Shown by GoRouter's `errorBuilder` for any unknown/unmatched route, and
/// re-used for auth-loading / unauthorized states where a friendly screen
/// is needed instead of a raw exception. Never surfaces the raw
/// GoException / router error text to the user.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.errorBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 32,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? "The page you're looking for doesn't exist.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: 'Go to Dashboard',
                icon: Icons.home_rounded,
                onPressed: () => context.go(AppRoutes.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
