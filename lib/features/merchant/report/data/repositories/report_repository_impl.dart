import 'package:fe_gangsta_flutter/features/merchant/report/data/datasources/report_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Future<MerchantReportEntity> getReport({required DateTimeRangeValue period}) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromStr = dateFormat.format(period.start);
    final toStr = dateFormat.format(period.end);

    final results = await Future.wait([
      _remoteDataSource.fetchRevenueReport(fromDate: fromStr, toDate: toStr),
      _remoteDataSource.fetchTopMenusReport(fromDate: fromStr, toDate: toStr),
      _remoteDataSource.fetchOrdersByTableReport(fromDate: fromStr, toDate: toStr),
      _remoteDataSource.fetchDailySummaryReport(fromDate: fromStr, toDate: toStr),
    ]);

    return MerchantReportEntity(
      revenue: results[0] as ReportRevenueEntity,
      topMenus: results[1] as ReportTopMenusEntity,
      ordersByTable: results[2] as ReportOrdersByTableEntity,
      dailySummary: results[3] as ReportDailySummaryEntity,
    );
  }
}
