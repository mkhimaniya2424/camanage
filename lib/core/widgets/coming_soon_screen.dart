import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';

/// Generic stand-in screen for routes that are reserved in the routing
/// table but whose real screen doesn't exist in this codebase yet
/// (every "future module" route, plus /create-firm and /firm-pending —
/// see the PLACEHOLDER note in app_router.dart for why those two are
/// here instead of wired to real screens).
///
/// This intentionally contains zero business logic — no Supabase calls,
/// no fake data, no fake auth/tenant state. It only exists so the route
/// is navigable instead of 404ing while the real screen is being built.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
    this.subtitle = "This module hasn't been built yet.",
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      appBar: AppBar(
        backgroundColor: colors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textSecondary, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        title: Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.bg3,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: colors.glassBorderDim),
                ),
                child: Icon(icon, size: 30, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
