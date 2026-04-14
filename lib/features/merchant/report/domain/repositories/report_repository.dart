import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';

abstract class ReportRepository {
  Future<MerchantReportEntity> getReport({required DateTimeRangeValue period});
}

class DateTimeRangeValue {
  const DateTimeRangeValue({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
