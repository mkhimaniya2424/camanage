import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_theme.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/firm_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/firm.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  Firm? _firm;
  bool _loading = true;
  String? _error;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final firm = await FirmService.instance.getCurrentFirm();
      if (!mounted) return;
      setState(() {
        _firm = firm;
        _loading = false;
      });
      _fadeCtrl.forward();
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load subscription details.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bg1,
        border: Border(bottom: BorderSide(color: colors.glassBorderDim)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.textSecondary,
                  size: 18,
                ),
              ),
              Expanded(
                child: Text(
                  'Manage Subscription',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colors = context.appColors;
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }
    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _load);
    }

    final plan = (_firm?.subscriptionPlan ?? 'free').toLowerCase();
    final status = (_firm?.subscriptionStatus ?? 'active').toLowerCase();

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Current plan hero ──────────────────────────────────────────
          _CurrentPlanCard(plan: plan, status: status),
          const SizedBox(height: 28),

          // ── Section header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 16),
            child: Text(
              'AVAILABLE PLANS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.textSecondary,
              ),
            ),
          ),

          // ── Plan cards ─────────────────────────────────────────────────
          _PlanCard(
            name: 'Free',
            tag: 'free',
            price: '₹0',
            period: 'forever',
            description: 'Perfect for solo CAs just getting started.',
            features: const [
              _PlanFeature('Up to 5 clients', true),
              _PlanFeature('Basic document storage', true),
              _PlanFeature('Task management', true),
              _PlanFeature('Team members', false),
              _PlanFeature('Compliance tracker', false),
              _PlanFeature('Priority support', false),
            ],
            isCurrentPlan: plan == 'free',
            isPremiumCard: false,
            onUpgrade: null,
          ),
          const SizedBox(height: 16),

          _PlanCard(
            name: 'Premium',
            tag: 'premium',
            price: '₹999',
            period: '/ month',
            description: 'For growing CA firms that need full power.',
            features: const [
              _PlanFeature('Unlimited clients', true),
              _PlanFeature('Advanced document storage', true),
              _PlanFeature('Task management', true),
              _PlanFeature('Up to 10 team members', true),
              _PlanFeature('Compliance tracker', true),
              _PlanFeature('Priority support', true),
            ],
            isCurrentPlan: plan == 'premium',
            isPremiumCard: true,
            onUpgrade: plan == 'premium' ? null : _handleUpgrade,
          ),
          const SizedBox(height: 16),

          _PlanCard(
            name: 'Enterprise',
            tag: 'enterprise',
            price: 'Custom',
            period: 'pricing',
            description: 'For large CA firms with advanced requirements.',
            features: const [
              _PlanFeature('Unlimited clients', true),
              _PlanFeature('Unlimited document storage', true),
              _PlanFeature('Advanced workflows', true),
              _PlanFeature('Unlimited team members', true),
              _PlanFeature('Full compliance suite', true),
              _PlanFeature('Dedicated account manager', true),
            ],
            isCurrentPlan: plan == 'enterprise',
            isPremiumCard: false,
            onUpgrade: plan == 'enterprise' ? null : _handleContactSales,
          ),
          const SizedBox(height: 24),

          // ── Footer note ────────────────────────────────────────────────
          Center(
            child: Text(
              'All prices include GST. Cancel anytime.',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: const Color(0xFFF0B429), size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Redirecting to payment gateway…'),
            ),
          ],
        ),
        backgroundColor: colors.bg3,
      ),
    );
  }

  void _handleContactSales() {
    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mail_outline_rounded, color: colors.primary, size: 16),
            const SizedBox(width: 8),
            const Expanded(child: Text('Opening contact form…')),
          ],
        ),
        backgroundColor: colors.bg3,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Current Plan Hero Card
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, required this.status});

  final String plan;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPremium = plan == 'premium' || plan == 'enterprise';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: isPremium
            ? const LinearGradient(
                colors: [Color(0xFF6B3BE8), Color(0xFF9B5CF6), Color(0xFFD946EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [colors.bg2, colors.bg3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: isPremium
            ? null
            : Border.all(color: colors.glassBorderDim),
        boxShadow: isPremium
            ? const [
                BoxShadow(
                  color: Color(0x559B5CF6),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.white.withValues(alpha: 0.2)
                      : colors.bg3,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.card_membership_rounded,
                  color: isPremium ? Colors.white : colors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPremium
                            ? Colors.white.withValues(alpha: 0.75)
                            : colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plan[0].toUpperCase()}${plan.substring(1)} Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            isPremium ? Colors.white : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? (isPremium
                          ? Colors.white.withValues(alpha: 0.25)
                          : colors.success.withValues(alpha: 0.15))
                      : colors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: status == 'active'
                        ? (isPremium
                            ? Colors.white.withValues(alpha: 0.4)
                            : colors.success.withValues(alpha: 0.4))
                        : colors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: status == 'active'
                        ? (isPremium ? Colors.white : colors.success)
                        : colors.warning,
                  ),
                ),
              ),
            ],
          ),
          if (isPremium) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(
                    label: 'Clients', value: 'Unlimited', isPremium: true),
                _VerticalDivider(isPremium: true),
                _HeroStat(
                    label: 'Storage', value: '100 GB', isPremium: true),
                _VerticalDivider(isPremium: true),
                _HeroStat(
                    label: 'Team', value: '10 users', isPremium: true),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: colors.glassBorderDim,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(label: 'Clients', value: 'Up to 5', isPremium: false),
                _VerticalDivider(isPremium: false),
                _HeroStat(label: 'Storage', value: '1 GB', isPremium: false),
                _VerticalDivider(isPremium: false),
                _HeroStat(label: 'Team', value: '1 user', isPremium: false),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.isPremium,
  });

  final String label;
  final String value;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isPremium ? Colors.white : colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isPremium
                  ? Colors.white.withValues(alpha: 0.65)
                  : colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 1,
      height: 32,
      color: isPremium
          ? Colors.white.withValues(alpha: 0.2)
          : colors.glassBorderDim,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Plan Card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanFeature {
  const _PlanFeature(this.label, this.included);
  final String label;
  final bool included;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.tag,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.isCurrentPlan,
    required this.isPremiumCard,
    required this.onUpgrade,
  });

  final String name;
  final String tag;
  final String price;
  final String period;
  final String description;
  final List<_PlanFeature> features;
  final bool isCurrentPlan;
  final bool isPremiumCard;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: isPremiumCard
            ? (context.isDarkMode
                ? const Color(0xFF1A1130)
                : const Color(0xFFF8F3FF))
            : colors.bg2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPremiumCard
              ? const Color(0xFF9B5CF6).withValues(alpha: 0.4)
              : isCurrentPlan
                  ? colors.primary.withValues(alpha: 0.4)
                  : colors.glassBorderDim,
          width: isPremiumCard || isCurrentPlan ? 1.5 : 1,
        ),
        boxShadow: isPremiumCard
            ? [
                BoxShadow(
                  color: const Color(0xFF9B5CF6).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isPremiumCard
                                  ? const Color(0xFF9B5CF6)
                                  : colors.textPrimary,
                            ),
                          ),
                          if (isPremiumCard) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF4B84F),
                                    Color(0xFFF49909)
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isPremiumCard
                            ? const Color(0xFF9B5CF6)
                            : colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: isPremiumCard
                  ? const Color(0xFF9B5CF6).withValues(alpha: 0.2)
                  : colors.glassBorderDim,
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                for (final f in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: f.included
                                ? (isPremiumCard
                                    ? const Color(0xFF9B5CF6)
                                        .withValues(alpha: 0.15)
                                    : colors.success.withValues(alpha: 0.15))
                                : colors.bg3,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            f.included
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 12,
                            color: f.included
                                ? (isPremiumCard
                                    ? const Color(0xFF9B5CF6)
                                    : colors.success)
                                : colors.textDisabled,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          f.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: f.included
                                ? colors.textPrimary
                                : colors.textMuted,
                            fontWeight: f.included
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onUpgrade != null) ...[
                  const SizedBox(height: 4),
                  _PlanActionButton(
                    isPremiumCard: isPremiumCard,
                    label: tag == 'enterprise' ? 'Contact Sales' : 'Upgrade Now',
                    icon: tag == 'enterprise'
                        ? Icons.mail_outline_rounded
                        : Icons.rocket_launch_rounded,
                    onTap: onUpgrade!,
                  ),
                ] else if (isCurrentPlan) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.bg3,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        '✓  Active Plan',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanActionButton extends StatefulWidget {
  const _PlanActionButton({
    required this.isPremiumCard,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool isPremiumCard;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PlanActionButton> createState() => _PlanActionButtonState();
}

class _PlanActionButtonState extends State<_PlanActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isPremiumCard
                ? const LinearGradient(
                    colors: [Color(0xFF6B3BE8), Color(0xFF9B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [colors.primaryDark, colors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: widget.isPremiumCard
                    ? const Color(0xFF9B5CF6).withValues(alpha: 0.3)
                    : colors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
