import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';
import 'widgets/dashboard_components.dart';

/// Main authenticated dashboard screen for CA Desk.
/// Renders a responsive layout:
///   - Wide (>1100px): Main column + Right info panel
///   - Narrow: Single scroll column
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Profile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.instance.fetchCurrentProfile();
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _displayName {
    if (_profile?.fullName?.isNotEmpty == true) {
      return _profile!.fullName!.split(' ').first;
    }
    return _profile?.email?.split('@').first ?? 'there';
  }

  String get _email => _profile?.email ?? '';

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'Super Admin';
      case UserRole.ca: return 'CA Owner';
      case UserRole.staff: return 'Staff';
      case UserRole.client: return 'Client';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isWide = MediaQuery.of(context).size.width > 1100;

    if (_loading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    return Scaffold(
      backgroundColor: colors.bg1,
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildMainContent(colors),
                ),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: colors.bg1,
                    border: Border(left: BorderSide(color: colors.glassBorderDim)),
                  ),
                  child: _buildRightPanel(colors),
                ),
              ],
            )
          : _buildMainContent(colors),
    );
  }

  // ───────────────────────── MAIN CONTENT ─────────────────────────

  Widget _buildMainContent(AppThemeExtension colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(colors),
          const SizedBox(height: 24),
          _buildQuickActions(colors),
          const SizedBox(height: 32),
          _buildKpiGrid(colors),
          const SizedBox(height: 32),
          _buildWorkSummary(colors),
          const SizedBox(height: 32),
          _buildComplianceAndDeadlines(colors),
          const SizedBox(height: 32),
          _buildDocumentRequests(colors),
          const SizedBox(height: 32),
          _buildMyTasks(colors),
          const SizedBox(height: 32),
          _buildRecentClients(colors),
          const SizedBox(height: 32),
          _buildRecentActivity(colors),
          const SizedBox(height: 80), // bottom nav safety
        ],
      ),
    );
  }

  // ───────────────────────── WELCOME HEADER ─────────────────────────

  Widget _buildWelcomeHeader(AppThemeExtension colors) {
    final role = _profile?.role ?? UserRole.staff;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                _displayName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 13, color: colors.textMuted),
                  const SizedBox(width: 4),
                  Text(_email, style: TextStyle(fontSize: 13, color: colors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, size: 13, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                _roleLabel(role),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── QUICK ACTIONS ─────────────────────────

  Widget _buildQuickActions(AppThemeExtension colors) {
    final actions = [
      _QuickAction(label: '+ Add Client', icon: Icons.person_add_rounded, color: colors.primary),
      _QuickAction(label: '+ New Task', icon: Icons.add_task_rounded, color: colors.secondary),
      _QuickAction(label: '+ Upload Doc', icon: Icons.upload_file_rounded, color: colors.tertiary),
      const _QuickAction(label: '+ Create Invoice', icon: Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
      _QuickAction(label: '+ New Engagement', icon: Icons.work_outline_rounded, color: colors.success),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _QuickActionButton(action: a, colors: colors),
        )).toList(),
      ),
    );
  }

  // ───────────────────────── KPI GRID ─────────────────────────

  Widget _buildKpiGrid(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(title: 'Overview'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
            const double childHeight = 130.0;
            final rows = (6 / crossAxisCount).ceil();
            return SizedBox(
              height: rows * (childHeight + 12) - 12,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth > 700
                    ? (constraints.maxWidth - 24) / 3 / childHeight
                    : (constraints.maxWidth - 12) / 2 / childHeight,
                children: [
                  DashboardKpiCard(label: 'Total Clients', value: '0', icon: Icons.people_alt_rounded, color: colors.primary),
                  DashboardKpiCard(label: 'Active Engagements', value: '0', icon: Icons.work_rounded, color: colors.secondary),
                  DashboardKpiCard(label: 'Pending Tasks', value: '0', icon: Icons.task_alt_rounded, color: colors.warning),
                  DashboardKpiCard(label: 'Due in 7 Days', value: '0', icon: Icons.calendar_today_rounded, color: colors.error),
                  DashboardKpiCard(label: 'Pending Documents', value: '0', icon: Icons.description_rounded, color: colors.tertiary),
                  const DashboardKpiCard(label: 'Outstanding (₹)', value: '₹0', icon: Icons.currency_rupee_rounded, color: Color(0xFF8B5CF6)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ───────────────────────── WORK SUMMARY ─────────────────────────

  Widget _buildWorkSummary(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(title: 'Work Summary'),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.glassBorderDim),
          ),
          child: Row(
            children: [
              DashboardWorkSummaryItem(label: 'Pending\nTasks', count: 0, color: colors.warning, icon: Icons.schedule_rounded),
              DashboardWorkSummaryItem(label: 'Completed\nTasks', count: 0, color: colors.success, icon: Icons.check_circle_rounded),
              DashboardWorkSummaryItem(label: 'Overdue\nTasks', count: 0, color: colors.error, icon: Icons.alarm_rounded),
              DashboardWorkSummaryItem(label: 'Pending\nReview', count: 0, color: colors.tertiary, icon: Icons.rate_review_rounded),
              _WorkSummaryLastItem(label: 'Pending\nApproval', count: 0, color: const Color(0xFF8B5CF6), icon: Icons.approval_rounded, colors: colors),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── COMPLIANCE & DEADLINES ─────────────────────────

  Widget _buildComplianceAndDeadlines(AppThemeExtension colors) {
    final isWide = MediaQuery.of(context).size.width > 800;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildComplianceOverview(colors)),
          const SizedBox(width: 16),
          Expanded(child: _buildUpcomingDeadlines(colors)),
        ],
      );
    }
    return Column(
      children: [
        _buildComplianceOverview(colors),
        const SizedBox(height: 16),
        _buildUpcomingDeadlines(colors),
      ],
    );
  }

  Widget _buildComplianceOverview(AppThemeExtension colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Compliance Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('View All', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Empty state for compliance
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.gavel_rounded, size: 40, color: colors.textMuted),
                  const SizedBox(height: 12),
                  Text('No compliance items configured', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Set up compliance types to track GST, TDS, ITR, etc.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colors.textDisabled)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines(AppThemeExtension colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Deadlines', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('View All', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 40, color: colors.textMuted),
                  const SizedBox(height: 12),
                  Text('No upcoming deadlines', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Deadlines will appear when clients and engagements are added.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colors.textDisabled)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── DOCUMENT REQUESTS ─────────────────────────

  Widget _buildDocumentRequests(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Documents Requiring Attention',
          actionLabel: 'View All',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        DashboardEmptyState(
          title: 'No document requests',
          message: 'Upload or request your first document from a client.',
          actionLabel: 'Upload Document',
          onAction: () {},
        ),
      ],
    );
  }

  // ───────────────────────── MY TASKS ─────────────────────────

  Widget _buildMyTasks(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'My Tasks',
          actionLabel: 'View All',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        // Task tabs
        _TaskTabBar(colors: colors),
        const SizedBox(height: 16),
        DashboardEmptyState(
          title: 'No tasks assigned',
          message: 'Create a task to start managing your work.',
          actionLabel: 'Create Task',
          onAction: () {},
        ),
      ],
    );
  }

  // ───────────────────────── RECENT CLIENTS ─────────────────────────

  Widget _buildRecentClients(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Recent Clients',
          actionLabel: 'View All Clients',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        DashboardEmptyState(
          title: 'No clients yet',
          message: 'Add your first client to get started.',
          actionLabel: 'Add Client',
          onAction: () {},
        ),
      ],
    );
  }

  // ───────────────────────── RECENT ACTIVITY ─────────────────────────

  Widget _buildRecentActivity(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(title: 'Recent Activity'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.glassBorderDim),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 40, color: colors.textMuted),
                  const SizedBox(height: 12),
                  Text('No recent activity', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Actions like uploads, task updates, and invoice creation will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colors.textDisabled)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── RIGHT PANEL ─────────────────────────

  Widget _buildRightPanel(AppThemeExtension colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's summary
          _buildTodaySummary(colors),
          const SizedBox(height: 24),
          // Upcoming Meetings
          _buildUpcomingMeetings(colors),
          const SizedBox(height: 24),
          // Quick Actions Panel
          _buildRightQuickActions(colors),
          const SizedBox(height: 24),
          // Recent Clients Panel
          _buildRightRecentClients(colors),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(AppThemeExtension colors) {
    final now = DateTime.now();
    final dateStr = '${_dayOfWeek(now.weekday)}, ${_monthName(now.month)} ${now.day}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dateStr, style: TextStyle(fontSize: 12, color: colors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _TodayChip(label: '0 Tasks', icon: Icons.task_alt_rounded, colors: colors),
            const SizedBox(width: 8),
            _TodayChip(label: '0 Meetings', icon: Icons.video_call_rounded, colors: colors),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _TodayChip(label: '0 Deadlines', icon: Icons.calendar_today_rounded, colors: colors),
            const SizedBox(width: 8),
            _TodayChip(label: '0 Reviews', icon: Icons.rate_review_rounded, colors: colors),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingMeetings(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Appointments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text('View all', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.glassBorderDim),
          ),
          child: Column(
            children: [
              Icon(Icons.event_available_rounded, size: 36, color: colors.textMuted),
              const SizedBox(height: 12),
              Text('No appointments scheduled yet', style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Create a new appointment or check back later.', style: TextStyle(fontSize: 11, color: colors.textMuted), textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightQuickActions(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.glassBorderDim),
          ),
          child: Column(
            children: [
              _RightQuickAction(icon: Icons.currency_rupee_rounded, label: 'Record Payment', colors: colors, onTap: () {}),
              Divider(height: 1, color: colors.glassBorderDim),
              _RightQuickAction(icon: Icons.add_circle_outline_rounded, label: 'Create Reminder', colors: colors, onTap: () {}),
              Divider(height: 1, color: colors.glassBorderDim),
              _RightQuickAction(icon: Icons.upload_file_rounded, label: 'Upload Document', colors: colors, onTap: () {}),
              Divider(height: 1, color: colors.glassBorderDim),
              _RightQuickAction(icon: Icons.bar_chart_rounded, label: 'Generate Report', colors: colors, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightRecentClients(AppThemeExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Clients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text('View all', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.glassBorderDim),
          ),
          child: Column(
            children: [
              Icon(Icons.people_alt_outlined, size: 36, color: colors.textMuted),
              const SizedBox(height: 12),
              Text('No clients yet', style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text('Add Client', textAlign: TextAlign.center, style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── HELPERS ─────────────────────────

  String _dayOfWeek(int wd) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(wd - 1).clamp(0, 6)];
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction({required this.label, required this.icon, required this.color});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  final AppThemeExtension colors;
  const _QuickActionButton({required this.action, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.bg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.glassBorderDim),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 15, color: action.color),
            const SizedBox(width: 8),
            Text(action.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _WorkSummaryLastItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final AppThemeExtension colors;

  const _WorkSummaryLastItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _TaskTabBar extends StatefulWidget {
  final AppThemeExtension colors;
  const _TaskTabBar({required this.colors});

  @override
  State<_TaskTabBar> createState() => _TaskTabBarState();
}

class _TaskTabBarState extends State<_TaskTabBar> {
  int _selected = 0;
  final _tabs = ['All', 'Today', 'Upcoming', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? widget.colors.primary : widget.colors.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? widget.colors.primary : widget.colors.glassBorderDim,
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : widget.colors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppThemeExtension colors;

  const _TodayChip({required this.label, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _RightQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeExtension colors;
  final VoidCallback onTap;

  const _RightQuickAction({required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

