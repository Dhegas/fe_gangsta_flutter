import 'dart:ui';

import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class MerchantTopBar extends StatelessWidget {
  const MerchantTopBar({
    super.key,
    required this.onSearchChanged,
    this.isCompact = false,
  });

  final ValueChanged<String> onSearchChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.72) : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14191C1E),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceNeutral,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                      hintText: 'Search menu items...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? const Color(0xFF64748B) : AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: AppSpacing.space4),
                const _TopActionIcon(icon: Icons.notifications_none_outlined),
                const SizedBox(width: AppSpacing.space2),
                const _TopActionIcon(icon: Icons.help_outline_rounded),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
      ),
    );
  }
}
