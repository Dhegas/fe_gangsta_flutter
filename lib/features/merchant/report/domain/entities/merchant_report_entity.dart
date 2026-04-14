import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_customer_insight_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_financial_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_sales_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_summary_entity.dart';

class MerchantReportEntity {
  const MerchantReportEntity({
    required this.summary,
    required this.sales,
    required this.financial,
    required this.customerInsight,
  });

  final ReportSummaryEntity summary;
  final ReportSalesEntity sales;
  final ReportFinancialEntity financial;
  final ReportCustomerInsightEntity customerInsight;
}
