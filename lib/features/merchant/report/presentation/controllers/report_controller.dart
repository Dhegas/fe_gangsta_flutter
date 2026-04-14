import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_period.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/repositories/report_repository.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/usecases/get_merchant_report.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/state/report_state.dart';
import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  ReportController({required GetMerchantReport getMerchantReport})
      : _getMerchantReport = getMerchantReport,
        _state = ReportState.initial();

  final GetMerchantReport _getMerchantReport;

  ReportState _state;
  ReportState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final report = await _getMerchantReport(
      period: DateTimeRangeValue(start: _state.rangeStart, end: _state.rangeEnd),
    );

    _state = _state.copyWith(isLoading: false, report: report);
    notifyListeners();
  }

  Future<void> selectPreset(ReportPreset preset) async {
    final now = DateTime.now();
    DateTime start;

    switch (preset) {
      case ReportPreset.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ReportPreset.thisWeek:
        final weekdayOffset = now.weekday - 1;
        start = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekdayOffset));
        break;
      case ReportPreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportPreset.custom:
        start = _state.rangeStart;
        break;
    }

    _state = _state.copyWith(preset: preset, rangeStart: start, rangeEnd: now);
    notifyListeners();
    await load();
  }

  Future<void> pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _state.rangeStart, end: _state.rangeEnd),
    );

    if (picked == null) {
      return;
    }

    _state = _state.copyWith(
      preset: ReportPreset.custom,
      rangeStart: picked.start,
      rangeEnd: picked.end,
    );
    notifyListeners();
    await load();
  }

  void toggleComparison(bool value) {
    _state = _state.copyWith(isComparing: value);
    notifyListeners();
  }
}
