import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Tappable banner shown in the profile screen under the BUSINESS section.
/// Displays the firm's current plan (Premium) with a styled badge.
class PremiumPlanBanner extends StatefulWidget {
  const PremiumPlanBanner({super.key, this.onTap, this.plan});

  final VoidCallback? onTap;

  /// e.g. 'free', 'premium', 'enterprise'. Defaults to 'premium'.
  final String? plan;

  @override
  State<PremiumPlanBanner> createState() => _PremiumPlanBannerState();
}

class _PremiumPlanBannerState extends State<PremiumPlanBanner>
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
    _scale = Tween<double>(begin: 1.0, end: 0.97)
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
    final plan = widget.plan ?? 'premium';
    final isPremium = plan == 'premium' || plan == 'enterprise';

    final planLabel =
        '${plan[0].toUpperCase()}${plan.substring(1)} Plan';

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isPremium
                ? const Color(0xFF9B5CF6).withValues(alpha: 0.07)
                : colors.bg2,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isPremium
                  ? const Color(0xFF9B5CF6).withValues(alpha: 0.25)
                  : colors.glassBorderDim,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isPremium
                    ? const Color(0xFF9B5CF6).withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient icon circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isPremium
                      ? const LinearGradient(
                          colors: [Color(0xFF6B3BE8), Color(0xFFD946EF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [colors.primaryDark, colors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isPremium
                          ? const Color(0xFF9B5CF6).withValues(alpha: 0.35)
                          : colors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.card_membership_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      planLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isPremium
                            ? const Color(0xFF9B5CF6)
                            : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manage Subscription',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge + chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF4B84F), Color(0xFFF49909)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      plan.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
