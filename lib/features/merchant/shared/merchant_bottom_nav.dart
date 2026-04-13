import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:flutter/material.dart';

class MerchantBottomNav extends StatelessWidget {
  const MerchantBottomNav({
    super.key,
    required this.selectedItem,
    this.onTapItem,
  });

  final MerchantNavItem selectedItem;
  final ValueChanged<MerchantNavItem>? onTapItem;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedItem.index,
      onDestinationSelected: (index) {
        if (index >= 0 && index < MerchantNavItem.values.length) {
          onTapItem?.call(MerchantNavItem.values[index]);
        }
      },
      backgroundColor: AppColors.surfaceSoft,
      indicatorColor: const Color(0xFFFFE6D9),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          selectedIcon: Icon(Icons.point_of_sale, color: AppColors.primary),
          label: 'POS',
        ),
        NavigationDestination(
          icon: Icon(Icons.table_restaurant_outlined),
          selectedIcon: Icon(Icons.table_restaurant, color: AppColors.primary),
          label: 'Tables',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(Icons.insert_chart_outlined),
          selectedIcon: Icon(Icons.insert_chart, color: AppColors.primary),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: AppColors.primary),
          label: 'Settings',
        ),
        NavigationDestination(
          icon: Icon(Icons.support_agent_outlined),
          selectedIcon: Icon(Icons.support_agent, color: AppColors.primary),
          label: 'Support',
        ),
      ],
    );
  }
}
