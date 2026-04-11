import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:flutter/material.dart';

class TenantCard extends StatelessWidget {
  const TenantCard({
    required this.tenant,
    super.key,
  });

  final TenantEntity tenant;

  Color get _statusColor =>
      tenant.status == 'active' ? AppColors.secondary : AppColors.textSecondary;

  Color get _statusBg => tenant.status == 'active'
      ? AppColors.secondary.withOpacity(0.1)
      : AppColors.surfaceStrong;

  Color get _planColor {
    switch (tenant.subscriptionPlan.toLowerCase()) {
      case 'enterprise':
        return AppColors.primary;
      case 'pro':
        return const Color(0xFF6366F1);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            // Avatar / icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tenant.ownerName,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  // Badges
                  Wrap(
                    spacing: AppSpacing.space2,
                    runSpacing: AppSpacing.space1,
                    children: [
                      _Badge(
                        label: tenant.status == 'active' ? 'Aktif' : 'Nonaktif',
                        color: _statusColor,
                        bg: _statusBg,
                        icon: tenant.status == 'active'
                            ? Icons.circle
                            : Icons.remove_circle_outline,
                      ),
                      _Badge(
                        label: tenant.subscriptionPlan,
                        color: _planColor,
                        bg: _planColor.withOpacity(0.1),
                        icon: Icons.workspace_premium_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space1),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
