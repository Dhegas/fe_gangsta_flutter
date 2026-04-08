import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:flutter/material.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<MenuCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedId;

          return ChoiceChip(
            label: Text(category.name),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.primary.withValues(alpha: 0.14),
            backgroundColor: AppColors.surfaceBase,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
            onSelected: (_) => onSelected(category.id),
          );
        },
      ),
    );
  }
}
