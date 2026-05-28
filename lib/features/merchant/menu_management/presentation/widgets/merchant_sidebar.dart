import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/main.dart';
import 'package:fe_gangsta_flutter/features/merchant/tenant_selection_page.dart';
import 'package:flutter/material.dart';

enum MerchantNavItem { pos, tables, orders, menuManagement, reports, settings }

class MerchantSidebar extends StatelessWidget {
   const MerchantSidebar({
    super.key,
    required this.merchantName,
    required this.merchantRoleLabel,
    this.selectedItem = MerchantNavItem.menuManagement,
    this.onTapItem,
  });

  final String merchantName;
  final String merchantRoleLabel;
  final MerchantNavItem selectedItem;
  final ValueChanged<MerchantNavItem>? onTapItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).scaffoldBackgroundColor == const Color(0xFF0F172A);

    return Container(
      width: 240,
      color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
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
                  color: isDarkMode ? const Color(0xFF334155) : AppColors.textPrimary,
                ),
                alignment: Alignment.center,
                child: Text(
                  merchantName.isNotEmpty ? merchantName[0].toUpperCase() : 'T',
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
                      style: textTheme.titleSmall?.copyWith(
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (context) => MerchantTenantSelectionPage(
                    onLogoutPressed: () {
                      AuthState.logout();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
                ),
                (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Pilih Outlet Lain',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          _SidebarMenuItem(
            icon: Icons.point_of_sale_outlined,
            label: 'POS',
            isSelected: selectedItem == MerchantNavItem.pos,
            onTap: () => onTapItem?.call(MerchantNavItem.pos),
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.table_restaurant_outlined,
            label: 'Tables',
            isSelected: selectedItem == MerchantNavItem.tables,
            onTap: () => onTapItem?.call(MerchantNavItem.tables),
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            isSelected: selectedItem == MerchantNavItem.orders,
            onTap: () => onTapItem?.call(MerchantNavItem.orders),
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.menu_book_outlined,
            label: 'Menu Management',
            isSelected: selectedItem == MerchantNavItem.menuManagement,
            onTap: () => onTapItem?.call(MerchantNavItem.menuManagement),
          ),
          const SizedBox(height: AppSpacing.space2),
          _SidebarMenuItem(
            icon: Icons.insert_chart_outlined,
            label: 'Reports',
            isSelected: selectedItem == MerchantNavItem.reports,
            onTap: () => onTapItem?.call(MerchantNavItem.reports),
          ),
          const Spacer(),
          _SidebarMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: selectedItem == MerchantNavItem.settings,
            onTap: () => onTapItem?.call(MerchantNavItem.settings),
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).scaffoldBackgroundColor == const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? AppColors.primary.withOpacity(0.15) : const Color(0xFFFFE6D9))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : isDarkMode
                      ? const Color(0xFF94A3B8)
                      : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.space3),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : isDarkMode
                        ? const Color(0xFFF1F5F9)
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
