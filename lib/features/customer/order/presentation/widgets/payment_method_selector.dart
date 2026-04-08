import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.methods,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final List<PaymentMethodEntity> methods;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: methods
          .map((method) {
            final isSelected = method.id == selectedId;
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => onChanged(method.id),
              child: Ink(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceStrong,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(method.name, style: textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            '${method.description} • Admin ${CurrencyFormatter.toRupiah(method.adminFee)}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
          .expand((tile) => [tile, const SizedBox(height: AppSpacing.space1)])
          .toList(),
    );
  }
}
