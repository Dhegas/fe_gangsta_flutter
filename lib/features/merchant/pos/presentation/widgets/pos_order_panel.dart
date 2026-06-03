import 'dart:ui';

import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
import 'package:flutter/material.dart';

class PosOrderPanel extends StatelessWidget {
  const PosOrderPanel({
    super.key,
    required this.salesChannel,
    required this.onSelectChannel,
    required this.orderLines,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.subtotal,
    required this.taxAmount,
    required this.grandTotal,
    required this.onClear,
    required this.onCheckout,
  });

  final PosSalesChannel salesChannel;
  final ValueChanged<PosSalesChannel> onSelectChannel;
  final List<PosOrderLineEntity> orderLines;
  final ValueChanged<String> onIncreaseQty;
  final ValueChanged<String> onDecreaseQty;
  final double subtotal;
  final double taxAmount;
  final double grandTotal;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.76) : Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14191C1E),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Order', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.space3),
              _ChannelSelector(
                salesChannel: salesChannel,
                onSelectChannel: onSelectChannel,
              ),
              const SizedBox(height: AppSpacing.space4),
              Expanded(
                child: orderLines.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada item di order.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: orderLines.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.space3),
                        itemBuilder: (context, index) {
                          final line = orderLines[index];
                          return _OrderLineTile(
                            line: line,
                            onIncrease: () => onIncreaseQty(line.itemId),
                            onDecrease: () => onDecreaseQty(line.itemId),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.space3),
              _AmountRow(label: 'Subtotal', value: _formatRupiah(subtotal)),
              const SizedBox(height: AppSpacing.space2),
              _AmountRow(
                label: 'Grand Total',
                value: _formatRupiah(grandTotal),
                highlight: true,
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClear,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: isDarkMode ? const Color(0xFF334155) : AppColors.surfaceSoft,
                        foregroundColor: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space3,
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFAB3500), AppColors.primary],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: onCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.space3,
                          ),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

class _ChannelSelector extends StatelessWidget {
  const _ChannelSelector({
    required this.salesChannel,
    required this.onSelectChannel,
  });

  final PosSalesChannel salesChannel;
  final ValueChanged<PosSalesChannel> onSelectChannel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: [
        _buildChannelChip(context, PosSalesChannel.dineIn, 'Makan di Tempat', Icons.restaurant_rounded),
        _buildChannelChip(context, PosSalesChannel.takeaway, 'Bawa Pulang', Icons.shopping_bag_rounded),
      ],
    );
  }

  Widget _buildChannelChip(
    BuildContext context,
    PosSalesChannel channel,
    String label,
    IconData icon,
  ) {
    final isSelected = salesChannel == channel;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onSelectChannel(channel),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: isSelected
              ? AppColors.primary
              : (isDarkMode ? const Color(0xFF334155) : AppColors.surfaceSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textSecondary),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderLineTile extends StatelessWidget {
  const _OrderLineTile({
    required this.line,
    required this.onIncrease,
    required this.onDecrease,
  });

  final PosOrderLineEntity line;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: textTheme.titleSmall),
                Text(
                  _formatRupiah(line.unitPrice),
                  style: textTheme.labelLarge?.copyWith(
                    color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _QtyButton(icon: Icons.remove_rounded, onTap: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
            child: Text(
              '${line.quantity}',
              style: textTheme.titleMedium,
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onIncrease),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF334155) : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: highlight
                ? textTheme.titleMedium
                : textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted,
                  ),
          ),
        ),
        Text(
          value,
          style: highlight
              ? textTheme.titleMedium?.copyWith(color: AppColors.primary)
              : textTheme.bodyMedium,
        ),
      ],
    );
  }
}
