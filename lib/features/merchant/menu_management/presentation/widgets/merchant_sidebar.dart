import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class MerchantSidebar extends StatelessWidget {
  const MerchantSidebar({
    super.key,
    required this.merchantName,
    required this.merchantRoleLabel,
  });

  final String merchantName;
  final String merchantRoleLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 240,
      color: AppColors.surfaceSoft,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space4,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  color: AppColors.textPrimary,
                ),
                alignment: Alignment.center,
                child: Text(
                  'B',
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    Text(
                      merchantRoleLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          _SidebarMenuItem(
            icon: Icons.point_of_sale_outlined,
            label: 'POS',
            isSelected: false,
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.table_restaurant_outlined,
            label: 'Tables',
            isSelected: false,
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.menu_book_outlined,
            label: 'Menu Management',
            isSelected: true,
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.insert_chart_outlined,
            label: 'Reports',
            isSelected: false,
          ),
          const Spacer(),
          _SidebarMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: false,
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.support_agent_outlined,
            label: 'Support',
            isSelected: false,
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE6D9) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.space3),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
