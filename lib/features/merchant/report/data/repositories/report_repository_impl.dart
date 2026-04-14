import 'package:fe_gangsta_flutter/features/merchant/report/data/datasources/report_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._localDataSource);

  final ReportLocalDataSource _localDataSource;

  @override
  Future<MerchantReportEntity> getReport({required DateTimeRangeValue period}) {
    return _localDataSource.getMockReport();
  }
}
