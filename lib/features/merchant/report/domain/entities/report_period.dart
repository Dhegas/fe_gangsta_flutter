enum ReportPreset { today, thisWeek, thisMonth, custom }

extension ReportPresetLabel on ReportPreset {
  String get label {
    switch (this) {
      case ReportPreset.today:
        return 'Hari Ini';
      case ReportPreset.thisWeek:
        return 'Minggu Ini';
      case ReportPreset.thisMonth:
        return 'Bulan Ini';
      case ReportPreset.custom:
        return 'Kustom';
    }
  }
}
