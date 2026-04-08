import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({required this.item, required this.onAddTap, super.key});

  final MenuItemEntity item;
  final VoidCallback onAddTap;

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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                item.imageUrl,
                width: 86,
                height: 86,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: 86,
                    height: 86,
                    color: AppColors.surfaceSoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    item.description,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatRupiah(item.price),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: onAddTap,
                          icon: const Icon(
                            Icons.add_shopping_cart_outlined,
                            size: 16,
                          ),
                          label: const Text('Tambah'),
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
