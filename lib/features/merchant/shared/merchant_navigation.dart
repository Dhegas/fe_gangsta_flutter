import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/pages/menu_management_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/pages/pos_page.dart';
import 'package:flutter/material.dart';

void navigateToMerchantSection(
  BuildContext context,
  MerchantNavItem target,
  MerchantNavItem current,
) {
  if (target == current) {
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    return;
  }

  Widget destination;

  switch (target) {
    case MerchantNavItem.pos:
      destination = const PosPage();
      break;
    case MerchantNavItem.menuManagement:
      destination = const MenuManagementPage();
      break;
    case MerchantNavItem.tables:
    case MerchantNavItem.reports:
    case MerchantNavItem.settings:
    case MerchantNavItem.support:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Halaman ${target.label} akan segera tersedia.')),
      );
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
      return;
  }

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => destination),
  );
}

extension MerchantNavItemLabel on MerchantNavItem {
  String get label {
    switch (this) {
      case MerchantNavItem.pos:
        return 'POS';
      case MerchantNavItem.tables:
        return 'Tables';
      case MerchantNavItem.menuManagement:
        return 'Menu Management';
      case MerchantNavItem.reports:
        return 'Reports';
      case MerchantNavItem.settings:
        return 'Settings';
      case MerchantNavItem.support:
        return 'Support';
    }
  }
}
