import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/pages/customer_menu_digital_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/pages/pos_page.dart';
import 'package:flutter/material.dart';

class GangstaApp extends StatelessWidget {
  const GangstaApp.customer({super.key})
    : _home = const CustomerMenuDigitalPage(),
      _title = 'Gangsta Kuliner - Customer';

  const GangstaApp.merchant({super.key})
    : _home = const PosPage(),
      _title = 'Gangsta Kuliner - Merchant';

  const GangstaApp.admin({super.key})
    : _home = const AdminDashboardPage(),
      _title = 'Gangsta Kuliner - Admin';

  final Widget _home;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _home,
    );
  }
}
