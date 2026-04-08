import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:flutter/material.dart';

class TenantCard extends StatelessWidget {
  const TenantCard({
    required this.tenant,
    super.key,
  });

  final TenantEntity tenant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Pemilik: ${tenant.ownerName}',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tenant.status == 'active' 
                            ? AppColors.secondary.withOpacity(0.1) 
                            : AppColors.neutral.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tenant.status.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: tenant.status == 'active' 
                                ? AppColors.secondary 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tenant.subscriptionPlan,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
