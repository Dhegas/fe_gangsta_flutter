import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/datasources/report_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/models/report_models.dart';

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<ReportRevenueModel> fetchRevenueReport({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/partner/reports/revenue?from=$fromDate&to=$toDate',
    );
    if (response != null && response['data'] != null) {
      return ReportRevenueModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat laporan revenue');
  }

  @override
  Future<ReportTopMenusModel> fetchTopMenusReport({
    required String fromDate,
    required String toDate,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/partner/reports/top-menus?from=$fromDate&to=$toDate&limit=$limit',
    );
    if (response != null && response['data'] != null) {
      return ReportTopMenusModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat laporan menu terlaris');
  }

  @override
  Future<ReportOrdersByTableModel> fetchOrdersByTableReport({
    required String fromDate,
    required String toDate,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/partner/reports/orders-by-table?from=$fromDate&to=$toDate&limit=$limit',
    );
    if (response != null && response['data'] != null) {
      return ReportOrdersByTableModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat laporan order per meja');
  }

  @override
  Future<ReportDailySummaryModel> fetchDailySummaryReport({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/partner/reports/daily-summary?from=$fromDate&to=$toDate',
    );
    if (response != null && response['data'] != null) {
      return ReportDailySummaryModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat laporan ringkasan harian');
  }
}
