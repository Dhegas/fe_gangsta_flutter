import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:flutter/material.dart';

class MerchantMenuItemCard extends StatelessWidget {
  const MerchantMenuItemCard({
    super.key,
    required this.item,
    required this.categoryLabel,
    required this.onToggleStock,
  });

  final MenuManagementItemEntity item;
  final String categoryLabel;
  final ValueChanged<bool> onToggleStock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D191C1E),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFFFE8DE),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  if (!item.isInStock)
                    Container(color: Colors.black.withValues(alpha: 0.32)),
                  Positioned(
                    top: AppSpacing.space2,
                    left: AppSpacing.space2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        categoryLabel.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF8A3A1B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.space2,
                    right: AppSpacing.space2,
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (!item.isInStock)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space3,
                          vertical: AppSpacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          'SOLD OUT',
                          style: textTheme.labelMedium?.copyWith(
                            letterSpacing: 1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      _formatRupiah(item.price),
                      style: textTheme.titleMedium?.copyWith(
                        color: item.isInStock
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Row(
                  children: [
                    Container(
                      height: 7,
                      width: 7,
                      decoration: BoxDecoration(
                        color: item.isInStock
                            ? AppColors.secondary
                            : const Color(0xFFB86A6A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (item.isInStock
                                    ? AppColors.secondary
                                    : const Color(0xFFB86A6A))
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        item.isInStock ? 'IN STOCK' : 'OUT OF STOCK',
                        style: textTheme.labelSmall?.copyWith(
                          color: item.isInStock
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.82,
                      child: Switch(
                        value: item.isInStock,
                        onChanged: onToggleStock,
                        activeTrackColor: AppColors.secondary,
                        activeThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFE3E8EE),
                        inactiveThumbColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double value) {
    final amount = value.round();
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }
}
