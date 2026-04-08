import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:flutter/material.dart';

class MenuManagementCategoryTabs extends StatelessWidget {
  const MenuManagementCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<MenuManagementCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category.id == selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () => onSelected(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  category.label,
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
