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
    required this.onToggleActive,
    required this.onSimulateOrder,
    required this.onEdit,
    required this.onDelete,
  });

  final MenuManagementItemEntity item;
  final String categoryLabel;
  final ValueChanged<bool> onToggleStock;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onSimulateOrder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
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
                  if (!item.isInStock || !item.isActive)
                    Container(color: Colors.black.withValues(alpha: 0.32)),
                  Positioned(
                    top: AppSpacing.space2,
                    left: AppSpacing.space2,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Badge(text: categoryLabel.toUpperCase()),
                        ...item.badges.map((badge) => _Badge(text: badge.label)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.space2,
                    right: AppSpacing.space2,
                    child: Row(
                      children: [
                        _IconAction(icon: Icons.edit_outlined, onTap: onEdit),
                        const SizedBox(width: 6),
                        _IconAction(icon: Icons.delete_outline, onTap: onDelete),
                      ],
                    ),
                  ),
                  if (!item.isInStock || !item.isActive)
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
                          !item.isActive ? 'NONAKTIF' : 'SOLD OUT',
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
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.space2),
                _PriceRow(item: item),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  'Porsi tersedia: ${item.remainingPortions}',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.space2),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _SmallChip(label: 'Varian ${item.variants.length}'),
                    _SmallChip(label: 'Add-on ${item.addOns.length}'),
                    _SmallChip(label: 'Catatan ${item.customNotes.length}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _SmallChip(label: 'Dine-in ${_formatRupiah(item.channelPricing.dineIn)}'),
                    _SmallChip(label: 'Takeaway ${_formatRupiah(item.channelPricing.takeaway)}'),
                    _SmallChip(label: 'Online ${_formatRupiah(item.channelPricing.online)}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.isInStock ? 'IN STOCK' : 'OUT OF STOCK',
                        style: textTheme.labelSmall,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.82,
                      child: Switch(
                        value: item.isInStock,
                        onChanged: onToggleStock,
                        activeTrackColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.isActive ? 'AKTIF' : 'NONAKTIF',
                        style: textTheme.labelSmall,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.82,
                      child: Switch(
                        value: item.isActive,
                        onChanged: onToggleActive,
                        activeTrackColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSimulateOrder,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: const Text('Simulasikan Pesanan Masuk'),
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
    final chunks = <String>[];
    for (int end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, end);
      chunks.insert(0, digits.substring(start, end));
    }
    return 'Rp ${chunks.join('.')}';
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.item});

  final MenuManagementItemEntity item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (item.discountedPrice == null) {
      return Text(
        _format(item.basePrice),
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      );
    }

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _format(item.basePrice),
          style: textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          _format(item.discountedPrice!),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _format(double value) {
    final amount = value.round();
    final digits = amount.toString();
    final chunks = <String>[];
    for (int end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, end);
      chunks.insert(0, digits.substring(start, end));
    }
    return 'Rp ${chunks.join('.')}';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF8A3A1B),
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
