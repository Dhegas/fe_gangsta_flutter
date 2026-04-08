import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class OrderTotalsCard extends StatelessWidget {
  const OrderTotalsCard({
    required this.subtotal,
    required this.additionalFee,
    required this.total,
    super.key,
  });

  final int subtotal;
  final int additionalFee;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          children: [
            _TotalRow(
              label: 'Subtotal',
              value: CurrencyFormatter.toRupiah(subtotal),
            ),
            const SizedBox(height: AppSpacing.space2),
            _TotalRow(
              label: 'Biaya tambahan',
              value: CurrencyFormatter.toRupiah(additionalFee),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
              child: Divider(height: 1),
            ),
            _TotalRow(
              label: 'Total pembayaran',
              value: CurrencyFormatter.toRupiah(total),
              valueStyle: textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(value, style: valueStyle ?? textTheme.titleSmall),
      ],
    );
  }
}
