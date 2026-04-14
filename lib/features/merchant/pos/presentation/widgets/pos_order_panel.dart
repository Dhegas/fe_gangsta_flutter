import 'dart:ui';

import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:flutter/material.dart';

class PosOrderPanel extends StatelessWidget {
  const PosOrderPanel({
    super.key,
    required this.tables,
    required this.selectedTableId,
    required this.onSelectTable,
    required this.orderLines,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.subtotal,
    required this.taxAmount,
    required this.grandTotal,
    required this.onClear,
    required this.onCheckout,
  });

  final List<PosTableEntity> tables;
  final String selectedTableId;
  final ValueChanged<String> onSelectTable;
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
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
              _TableSelector(
                tables: tables,
                selectedTableId: selectedTableId,
                onSelectTable: onSelectTable,
              ),
              const SizedBox(height: AppSpacing.space4),
              Expanded(
                child: orderLines.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada item di order.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textMuted,
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
              const SizedBox(height: AppSpacing.space1),
              _AmountRow(label: 'Tax 10%', value: _formatRupiah(taxAmount)),
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
                        backgroundColor: AppColors.surfaceSoft,
                        foregroundColor: AppColors.textSecondary,
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

class _TableSelector extends StatelessWidget {
  const _TableSelector({
    required this.tables,
    required this.selectedTableId,
    required this.onSelectTable,
  });

  final List<PosTableEntity> tables;
  final String selectedTableId;
  final ValueChanged<String> onSelectTable;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: tables.map((table) {
        final isSelected = table.id == selectedTableId;
        final statusColor = _statusColor(table.status);

        return InkWell(
          onTap: table.isSelectable ? () => onSelectTable(table.id) : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: isSelected
                  ? AppColors.primary
                  : table.isSelectable
                      ? AppColors.surfaceSoft
                      : AppColors.surfaceStrong,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isSelected ? Colors.white : statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  table.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                if (table.isPhysicalTable) ...[
                  const SizedBox(width: 6),
                  Text(
                    _statusLabel(table.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return AppColors.statusSuccess;
      case TableStatus.occupied:
        return AppColors.statusError;
      case TableStatus.reserved:
        return AppColors.statusWarning;
      case TableStatus.cleaning:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
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
                    color: AppColors.textSecondary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
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

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: highlight
                ? textTheme.titleMedium
                : textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
