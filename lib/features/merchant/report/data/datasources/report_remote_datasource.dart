import 'package:fe_gangsta_flutter/features/merchant/report/data/models/report_models.dart';

abstract class ReportRemoteDataSource {
  Future<ReportRevenueModel> fetchRevenueReport({
    required String fromDate,
    required String toDate,
  });

  Future<ReportTopMenusModel> fetchTopMenusReport({
    required String fromDate,
    required String toDate,
    int limit = 10,
  });

  Future<ReportOrdersByTableModel> fetchOrdersByTableReport({
    required String fromDate,
    required String toDate,
    int limit = 10,
  });

  Future<ReportDailySummaryModel> fetchDailySummaryReport({
    required String fromDate,
    required String toDate,
  });
}
