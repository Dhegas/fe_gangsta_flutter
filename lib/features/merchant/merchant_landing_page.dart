import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/pages/menu_management_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/pages/pos_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/pages/report_overview_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/pages/table_status_page.dart';
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
      MenuManagementPage(onNavigate: _handleNavigate),
      ReportOverviewPage(onNavigate: _handleNavigate),
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
      case MerchantNavItem.menuManagement:
        return 2;
      case MerchantNavItem.reports:
        return 3;
      case MerchantNavItem.settings:
      case MerchantNavItem.support:
        return 0;
    }
  }

  void _handleNavigate(MerchantNavItem target) {
    if (target == _currentItem) {
      return;
    }

    switch (target) {
      case MerchantNavItem.pos:
      case MerchantNavItem.tables:
      case MerchantNavItem.menuManagement:
      case MerchantNavItem.reports:
        setState(() {
          _currentItem = target;
        });
        break;
      case MerchantNavItem.settings:
      case MerchantNavItem.support:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Halaman ${_labelFor(target)} akan segera tersedia.'),
          ),
        );
        break;
    }
  }

  String _labelFor(MerchantNavItem item) {
    switch (item) {
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
