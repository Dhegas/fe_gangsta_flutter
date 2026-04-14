import 'package:fe_gangsta_flutter/features/merchant/report/presentation/pages/report_overview_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:flutter/material.dart';

class ReportMonthlyPage extends StatelessWidget {
  const ReportMonthlyPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return ReportOverviewPage(onNavigate: onNavigate);
  }
}
