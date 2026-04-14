class SalesByTimeEntity {
  const SalesByTimeEntity({
    required this.hourly,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  final double hourly;
  final double daily;
  final double weekly;
  final double monthly;
}

class SalesSegmentEntity {
  const SalesSegmentEntity({
    required this.label,
    required this.amount,
    required this.count,
  });

  final String label;
  final double amount;
  final int count;
}

class ReportSalesEntity {
  const ReportSalesEntity({
    required this.salesByTime,
    required this.paymentMethods,
    required this.orderStatuses,
    required this.channels,
  });

  final SalesByTimeEntity salesByTime;
  final List<SalesSegmentEntity> paymentMethods;
  final List<SalesSegmentEntity> orderStatuses;
  final List<SalesSegmentEntity> channels;
}
