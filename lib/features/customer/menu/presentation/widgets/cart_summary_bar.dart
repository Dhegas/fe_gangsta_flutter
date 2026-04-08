import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    required this.totalItems,
    required this.totalPrice,
    required this.onTap,
    super.key,
  });

  final int totalItems;
  final int totalPrice;
  final VoidCallback onTap;

  String _formatRupiah(int value) {
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space2,
          AppSpacing.space4,
          AppSpacing.space4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29152335),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                '$totalItems',
                style: textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item di keranjang',
                    style: textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    _formatRupiah(totalPrice),
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
