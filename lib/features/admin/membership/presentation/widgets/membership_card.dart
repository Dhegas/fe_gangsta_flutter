import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';
import 'package:flutter/material.dart';

class MembershipCard extends StatelessWidget {
  const MembershipCard({required this.membership, super.key});

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

  // Map each tier to its accent color
  Color get _accentColor {
    switch (membership.name.toLowerCase()) {
      case 'pro plan':
        return AppColors.primary;
      case 'enterprise plan':
        return const Color(0xFF6366F1);
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPopular = membership.isPopular;
    final accent = _accentColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        border: Border.all(
          color: isPopular ? accent.withOpacity(0.5) : AppColors.surfaceStrong,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isPopular ? 0.15 : 0.05),
            blurRadius: isPopular ? 24 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colored Header Banner ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space6,
                AppSpacing.space5,
                AppSpacing.space6,
                AppSpacing.space5,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withOpacity(0.75)],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPopular) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space3,
                              vertical: AppSpacing.space1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'PALING LAKU',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                        ],
                        Text(
                          membership.name,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(membership.price),
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space1),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(
                                '/ ${membership.billingCycle == 'monthly' ? 'bulan' : 'tahun'}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 52,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ],
              ),
            ),

            // ── Features List ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Termasuk',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  ...membership.features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 1),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: accent,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          Expanded(
                            child: Text(
                              feature,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: AppSpacing.space4),

                  // ── Action Button ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Paket'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.people_alt_outlined, size: 16),
                          label: const Text('Lihat Pelanggan'),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
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
    );
  }
}
