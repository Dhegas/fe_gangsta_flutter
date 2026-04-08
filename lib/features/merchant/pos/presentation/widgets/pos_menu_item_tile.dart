import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:flutter/material.dart';

class PosMenuItemTile extends StatelessWidget {
  const PosMenuItemTile({
    super.key,
    required this.item,
    required this.currentQty,
    required this.onAdd,
  });

  final PosMenuItemEntity item;
  final int currentQty;
  final VoidCallback onAdd;

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
            blurRadius: 20,
            offset: Offset(0, 10),
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
              aspectRatio: 1.45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFE8DE),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: AppSpacing.space2,
                    top: AppSpacing.space2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        _formatRupiah(item.price),
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: currentQty == 0
                        ? const Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.primary,
                          )
                        : Text(
                            'x$currentQty',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                  ),
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
