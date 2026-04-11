import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class StatSummaryCard extends StatefulWidget {
  const StatSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trendValue,
    this.isTrendPositive = true,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trendValue;
  final bool isTrendPositive;

  @override
  State<StatSummaryCard> createState() => _StatSummaryCardState();
}

class _StatSummaryCardState extends State<StatSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: AppColors.surfaceBase,
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.35)
                  : widget.color.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withOpacity(_isHovered ? 0.18 : 0.06),
                blurRadius: _isHovered ? 24 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              children: [
                // Subtle colored top stripe
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: Container(color: widget.color),
                ),
                // Watermark icon
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    widget.icon,
                    size: 120,
                    color: widget.color.withOpacity(0.07),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space5,
                    AppSpacing.space5 + 4, // account for top stripe
                    AppSpacing.space5,
                    AppSpacing.space5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon + trend pill row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 24,
                            ),
                          ),
                          if (widget.trendValue != null)
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.space2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.space3,
                                    vertical: AppSpacing.space1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.isTrendPositive
                                        ? AppColors.secondary.withOpacity(0.12)
                                        : AppColors.statusError.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.isTrendPositive
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                        color: widget.isTrendPositive
                                            ? AppColors.secondary
                                            : AppColors.statusError,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          widget.trendValue!,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: widget.isTrendPositive
                                                ? AppColors.secondary
                                                : AppColors.statusError,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Value + label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.value,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            widget.title,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
