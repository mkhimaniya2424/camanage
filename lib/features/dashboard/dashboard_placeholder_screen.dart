import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_theme.dart';
import '../../core/config/theme_controller.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';

/// Temporary post-login landing screen. Confirms auth end-to-end (shows
/// the signed-in user's email + role) until the real dashboard is built
/// (Task 12 / Phase 14 in the plan).
class DashboardPlaceholderScreen extends StatefulWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  State<DashboardPlaceholderScreen> createState() =>
      _DashboardPlaceholderScreenState();
}

class _DashboardPlaceholderScreenState
    extends State<DashboardPlaceholderScreen> {
  Profile? _profile;
  bool _loading = true;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await AuthService.instance.fetchCurrentProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    // The router's redirect also reacts to this sign-out automatically
    // (see AppRouter), but we navigate explicitly too so the UI moves
    // immediately rather than waiting on the auth-stream round trip.
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      extendBody: true,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  )
                : _error != null
                    ? AppErrorState(message: _error!, onRetry: _loadProfile)
                    : _buildDashboardBody(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildTopBar() {
    final colors = context.appColors;
    return Container(
      color: colors.bg1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'CA Desk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Theme Toggle
              GestureDetector(
                onTap: () => ThemeController.instance.toggleTheme(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.bg3,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.glassBorderDim),
                  ),
                  child: Icon(
                    ThemeController.instance.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Notification bell
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.bg3,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: colors.glassBorderDim),
                ),
                child: Icon(Icons.notifications_none_rounded, color: colors.textSecondary, size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Profile avatar
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Text(
                      (_profile?.fullName?.isNotEmpty == true
                              ? _profile!.fullName![0]
                              : _profile?.email?[0] ?? '?')
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardBody() {
    final colors = context.appColors;
    final profile = _profile;
    final email = profile?.email ??
        AuthService.instance.currentUser?.email ??
        'Unknown';
    final role = profile?.role ?? UserRole.staff;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.bg2,
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 120, // Avoid bottom nav overlap
        ),
        children: [
          // Welcome header
          _buildWelcomeCard(email, role),
          const SizedBox(height: 32),
          // Quick actions
          _buildQuickActions(),
          const SizedBox(height: 32),
          // Stat cards grid
          const AppSectionHeader(title: 'Overview'),
          const SizedBox(height: 16),
          _buildStatGrid(),
          const SizedBox(height: 32),
          // Coming soon modules
          const AppSectionHeader(title: 'Available Modules'),
          const SizedBox(height: 16),
          _buildModulesPreview(),
          const SizedBox(height: 48),
          // Sign out
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: Icon(Icons.error, color: colors.error,
            ),
            label: Text(
              'Sign Out',
              style: TextStyle(color: colors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colors.errorBg,
              ),
              backgroundColor: colors.errorBg,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String email, UserRole role) {
    final colors = context.appColors;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final name = _profile?.fullName?.isNotEmpty == true
        ? _profile!.fullName!.split(' ').first
        : email.split('@').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$greeting,',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            AppBadge(
              label: _roleLabel(role),
              color: colors.primary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.email_outlined, color: colors.textMuted, size: 14),
            const SizedBox(width: 6),
            Text(
              email,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          AppQuickAction(
            icon: Icons.person_add_rounded,
            label: 'Add Client',
            onTap: () {},
          ),
          const SizedBox(width: 12),
          AppQuickAction(
            icon: Icons.add_task_rounded,
            label: 'New Task',
            onTap: () {},
          ),
          const SizedBox(width: 12),
          AppQuickAction(
            icon: Icons.request_quote_rounded,
            label: 'New Invoice',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final colors = context.appColors;
    final stats = [
      _StatItem(
        label: 'Clients',
        value: '—',
        icon: Icons.people_alt_rounded,
        color: colors.primary,
      ),
      _StatItem(
        label: 'Tasks',
        value: '—',
        icon: Icons.task_alt_rounded,
        color: colors.secondary,
      ),
      _StatItem(
        label: 'Invoices',
        value: '—',
        icon: Icons.receipt_long_rounded,
        color: colors.warning,
      ),
      _StatItem(
        label: 'Deadlines',
        value: '—',
        icon: Icons.calendar_today_rounded,
        color: colors.error,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: stats
          .map((s) => AppStatCard(
                label: s.label,
                value: s.value,
                icon: s.icon,
                color: s.color,
              ))
          .toList(),
    );
  }

  Widget _buildModulesPreview() {
    final colors = context.appColors;
    final modules = [
      ('Clients', Icons.people_alt_rounded),
      ('Tasks', Icons.task_alt_rounded),
      ('Documents', Icons.folder_rounded),
      ('Invoices', Icons.receipt_long_rounded),
      ('Payments', Icons.payment_rounded),
      ('Deadlines', Icons.event_rounded),
      ('Reports', Icons.bar_chart_rounded),
    ];
    
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: modules
            .map(
              (m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.bg1,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.glassBorderDim),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.$2, size: 14, color: colors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      m.$1,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomNav() {
    final colors = context.appColors;
    const items = [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavItem(icon: Icons.people_alt_rounded, label: 'Clients'),
      _NavItem(icon: Icons.task_alt_rounded, label: 'Tasks'),
      _NavItem(icon: Icons.receipt_long_rounded, label: 'Invoices'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.bg2.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  if (i == 4) {
                    context.push(AppRoutes.profile);
                    return;
                  }
                  setState(() => _selectedIndex = i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: selected ? colors.primary : colors.textMuted,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.ca:
        return 'CA Owner';
      case UserRole.staff:
        return 'Staff';
      case UserRole.client:
        return 'Client';
    }
  }

}

class _StatItem {
  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
