import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_home_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/pages/pos_page.dart';
import 'package:flutter/material.dart';

class GangstaApp extends StatelessWidget {
  const GangstaApp.customer({super.key})
    : _home = const CustomerHomePage(),
      _title = 'Gangsta Kuliner - Customer';

  const GangstaApp.merchant({super.key})
    : _home = const PosPage(),
      _title = 'Gangsta Kuliner - Merchant';

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
