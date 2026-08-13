import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../core/config/theme_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

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
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bg1,
        border: Border(
          bottom: BorderSide(color: colors.glassBorderDim),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primaryDark, colors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ).createShader(bounds),
                child: Text(
                  'CA Desk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primaryDark, colors.tertiary],
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
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome header
          _buildWelcomeCard(email, role),
          const SizedBox(height: 20),
          // Stat cards grid
          _buildStatGrid(),
          const SizedBox(height: 20),
          // Coming soon modules
          _buildModulesPreview(),
          const SizedBox(height: 20),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF1A2233)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: _roleLabel(role),
                color: _roleColor(role),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.glassBorderDim),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info, color: colors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                email,
                style: TextStyle(color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: stats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(stat.icon, color: stat.color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: TextStyle(color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                stat.label,
                style: TextStyle(color: colors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulesPreview() {
    final colors = context.appColors;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Modules coming soon',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Clients',
              'Tasks',
              'Documents',
              'Invoices',
              'Payments',
              'Deadlines',
              'Notifications',
              'Reports',
            ]
                .map(
                  (m) => AppBadge(
                    label: m,
                    color: colors.textMuted,
                  ),
                )
                .toList(),
          ),
        ],
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
        color: colors.bg2,
        border: Border(
          top: BorderSide(color: colors.glassBorderDim),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  if (i == 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                    return;
                  }
                  setState(() => _selectedIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: selected
                            ? colors.primary
                            : colors.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? colors.primary
                              : colors.textMuted,
                        ),
                      ),
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

  Color _roleColor(UserRole role) {
    final colors = context.appColors;
    switch (role) {
      case UserRole.superAdmin:
        return colors.tertiary;
      case UserRole.ca:
        return colors.primary;
      case UserRole.staff:
        return colors.secondary;
      case UserRole.client:
        return colors.warning;
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
