import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/pages/customer_menu_digital_page.dart';
import 'package:flutter/material.dart';

class GangstaApp extends StatelessWidget {
  const GangstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gangsta Kuliner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const CustomerMenuDigitalPage(),
    );
  }
}
