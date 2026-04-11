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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              child: Image.network(
                item.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
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
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  item.description,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  _formatRupiah(item.price),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onAddTap,
                    child: const Text('Tambah'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
