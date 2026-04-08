import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';
import 'package:flutter/material.dart';

class MembershipCard extends StatelessWidget {
  const MembershipCard({
    required this.membership,
    super.key,
  });

  final MembershipEntity membership;

  String _formatCurrency(int value) {
    if (value == 0) return 'Gratis';
    final reversed = value.toString().split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }
    return 'Rp ${chunks.reversed.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = membership.isPopular ? AppColors.primary : AppColors.surfaceStrong;

    return Card(
      elevation: membership.isPopular ? 4 : 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: primaryColor,
          width: membership.isPopular ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (membership.isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PALING LAKU',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
            ],
            Text(
              membership.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: membership.isPopular ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(membership.price),
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: membership.isPopular ? AppColors.primary : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  '/${membership.billingCycle == 'monthly' ? 'bulan' : 'tahun'}',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            const Divider(),
            const SizedBox(height: AppSpacing.space4),
            ...membership.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        feature,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: AppSpacing.space4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: membership.isPopular ? AppColors.primary : AppColors.surfaceSoft,
                  foregroundColor: membership.isPopular ? Colors.white : AppColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Edit Paket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
