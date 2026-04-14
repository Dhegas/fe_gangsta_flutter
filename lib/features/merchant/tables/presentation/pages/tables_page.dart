import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/pages/table_status_page.dart';
import 'package:flutter/material.dart';

@Deprecated('Use TableStatusPage from table_management feature path.')
class TablesPage extends StatelessWidget {
  const TablesPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return TableStatusPage(onNavigate: onNavigate);
  }
}
