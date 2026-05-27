import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/pages/menu_management_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/presentation/pages/order_management_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/pages/pos_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/pages/report_overview_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/pages/table_status_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MerchantLandingPage extends StatefulWidget {
  const MerchantLandingPage({super.key});

  @override
  State<MerchantLandingPage> createState() => _MerchantLandingPageState();
}

class _MerchantLandingPageState extends State<MerchantLandingPage> {
  MerchantNavItem _currentItem = MerchantNavItem.pos;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PosPage(onNavigate: _handleNavigate),
      TableStatusPage(onNavigate: _handleNavigate),
      OrderManagementPage(onNavigate: _handleNavigate),
      MenuManagementPage(onNavigate: _handleNavigate),
      ReportOverviewPage(onNavigate: _handleNavigate),
      SettingsPage(onNavigate: _handleNavigate),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _stackIndexFor(_currentItem),
      children: _pages,
    );
  }

  int _stackIndexFor(MerchantNavItem item) {
    switch (item) {
      case MerchantNavItem.pos:
        return 0;
      case MerchantNavItem.tables:
        return 1;
      case MerchantNavItem.orders:
        return 2;
      case MerchantNavItem.menuManagement:
        return 3;
      case MerchantNavItem.reports:
        return 4;
      case MerchantNavItem.settings:
        return 5;
    }
  }

  void _handleNavigate(MerchantNavItem target) {
    if (target == _currentItem) {
      return;
    }

    switch (target) {
      case MerchantNavItem.pos:
      case MerchantNavItem.tables:
      case MerchantNavItem.orders:
      case MerchantNavItem.menuManagement:
      case MerchantNavItem.reports:
      case MerchantNavItem.settings:
        setState(() {
          _currentItem = target;
        });
        break;
    }
  }
}
