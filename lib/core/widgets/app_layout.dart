import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../config/theme_controller.dart';
import '../router/app_routes.dart';
import '../../models/profile.dart';
import '../../features/auth/auth_service.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  Profile? _profile;
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.instance.fetchCurrentProfile();
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: colors.bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.bg1, colors.bg1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            if (isDesktop)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: _isSidebarCollapsed ? 82 : 240,
                decoration: BoxDecoration(
                  color: colors.bg2,
                  border: Border(
                    right: BorderSide(color: colors.glassBorderDim, width: 1),
                  ),
                ),
                child: _buildSidebar(colors),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildTopHeader(colors, isDesktop),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(colors),
    );
  }

  Widget _buildTopHeader(AppThemeExtension colors, bool isDesktop) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colors.bg1,
          border: Border(bottom: BorderSide(color: colors.glassBorderDim, width: 1)),
        ),
        child: Row(
          children: [
            if (isDesktop)
              IconButton(
                onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                icon: Icon(
                  _isSidebarCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                  color: colors.textSecondary,
                ),
              ),
            const SizedBox(width: 8),
            if (!isDesktop)
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: colors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CA Desk',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            if (isDesktop)
              Container(
                width: 320,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.glassBorderDim),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: colors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search anything...',
                        style: TextStyle(color: colors.textMuted, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.bg3,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.glassBorderDim),
                      ),
                      child: Text(
                        '⌘K',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => ThemeController.instance.toggleTheme(),
              icon: Icon(
                ThemeController.instance.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: colors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, color: colors.textSecondary),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
    );
  }

  Widget _buildSidebar(AppThemeExtension colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 62,
            padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 0 : 18),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 10),
                  Text(
                    'CA Desk',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _isCurrentRoute(AppRoutes.dashboard),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.dashboard),
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Clients',
                  isSelected: _isCurrentRoute(AppRoutes.clients),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.clients),
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.task_alt_rounded,
                  label: 'Tasks',
                  isSelected: _isCurrentRoute(AppRoutes.tasks),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.tasks),
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Invoices',
                  isSelected: _isCurrentRoute(AppRoutes.billing),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.billing),
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.description_rounded,
                  label: 'Documents',
                  isSelected: _isCurrentRoute(AppRoutes.documents),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.documents),
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  isSelected: false,
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () {},
                  colors: colors,
                ),
                _SidebarItem(
                  icon: Icons.report_rounded,
                  label: 'Reports',
                  isSelected: false,
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () {},
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _SidebarItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _isCurrentRoute(AppRoutes.settings),
                  isCollapsed: _isSidebarCollapsed,
                  onTap: () => context.go(AppRoutes.settings),
                  colors: colors,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.bg1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.glassBorderDim),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: colors.primary, size: 18),
                      if (!_isSidebarCollapsed) const SizedBox(width: 8),
                      if (!_isSidebarCollapsed)
                        Expanded(
                          child: Text(
                            'Need Help?',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!_isSidebarCollapsed) ...[
                    const SizedBox(height: 8),
                    Text(
                      'We\'re here to help you succeed.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Contact Support'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentRoute(String route) {
    final location = GoRouterState.of(context).matchedLocation;
    return route == AppRoutes.dashboard ? location == route : location.startsWith(route);
  }

  Widget _buildBottomNav(AppThemeExtension colors) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith(AppRoutes.clients)) currentIndex = 1;
    if (location.startsWith(AppRoutes.tasks)) currentIndex = 2;
    if (location.startsWith(AppRoutes.documents)) currentIndex = 3;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg2,
        border: Border(top: BorderSide(color: colors.glassBorderDim, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isSelected: currentIndex == 0,
                onTap: () => context.go(AppRoutes.dashboard),
                colors: colors,
              ),
              _BottomNavItem(
                icon: Icons.people_alt_rounded,
                label: 'Clients',
                isSelected: currentIndex == 1,
                onTap: () => context.go(AppRoutes.clients),
                colors: colors,
              ),
              _BottomNavItem(
                icon: Icons.task_alt_rounded,
                label: 'Tasks',
                isSelected: currentIndex == 2,
                onTap: () => context.go(AppRoutes.tasks),
                colors: colors,
              ),
              _BottomNavItem(
                icon: Icons.description_rounded,
                label: 'Docs',
                isSelected: currentIndex == 3,
                onTap: () => context.go(AppRoutes.documents),
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final AppThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? colors.primary : colors.textSecondary,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? colors.primary : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 21, color: isSelected ? colors.primary : colors.textMuted),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.primary : colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
