class ReportSummaryEntity {
  const ReportSummaryEntity({
    required this.grossRevenue,
    required this.netRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.periodComparisonPercent,
    required this.trend,
  });

  final double grossRevenue;
  final double netRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final double periodComparisonPercent;
  final List<double> trend;
}
