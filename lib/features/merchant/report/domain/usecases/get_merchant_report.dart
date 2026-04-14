import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/repositories/report_repository.dart';

class GetMerchantReport {
  const GetMerchantReport(this._repository);

  final ReportRepository _repository;

  Future<MerchantReportEntity> call({required DateTimeRangeValue period}) {
    return _repository.getReport(period: period);
  }
}
