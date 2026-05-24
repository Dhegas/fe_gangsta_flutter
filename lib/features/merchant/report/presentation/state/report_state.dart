import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_period.dart';

class ReportState {
  const ReportState({
    required this.isLoading,
    required this.preset,
    required this.rangeStart,
    required this.rangeEnd,
    required this.isComparing,
    required this.report,
    required this.errorMessage,
  });

  factory ReportState.initial() {
    final now = DateTime.now();
    return ReportState(
      isLoading: true,
      preset: ReportPreset.thisMonth,
      rangeStart: DateTime(now.year, now.month, 1),
      rangeEnd: now,
      isComparing: true,
      report: null,
      errorMessage: '',
    );
  }

  final bool isLoading;
  final ReportPreset preset;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final bool isComparing;
  final MerchantReportEntity? report;
  final String errorMessage;

  ReportState copyWith({
    bool? isLoading,
    ReportPreset? preset,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    bool? isComparing,
    MerchantReportEntity? report,
    String? errorMessage,
    bool clearReport = false,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      preset: preset ?? this.preset,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      isComparing: isComparing ?? this.isComparing,
      report: clearReport ? null : (report ?? this.report),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
