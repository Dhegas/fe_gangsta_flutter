class MerchantReportEntity {
  const MerchantReportEntity({
    required this.revenue,
    required this.topMenus,
    required this.ordersByTable,
    required this.dailySummary,
  });

  final ReportRevenueEntity revenue;
  final ReportTopMenusEntity topMenus;
  final ReportOrdersByTableEntity ordersByTable;
  final ReportDailySummaryEntity dailySummary;
}

class ReportRevenueEntity {
  const ReportRevenueEntity({
    required this.from,
    required this.to,
    required this.totalRevenue,
    required this.totalOrders,
    required this.generatedAt,
  });

  final String from;
  final String to;
  final double totalRevenue;
  final int totalOrders;
  final DateTime generatedAt;
}

class ReportTopMenusEntity {
  const ReportTopMenusEntity({
    required this.from,
    required this.to,
    required this.menus,
  });

  final String from;
  final String to;
  final List<TopMenuEntryEntity> menus;
}

class TopMenuEntryEntity {
  const TopMenuEntryEntity({
    required this.rank,
    required this.menuId,
    required this.menuName,
    required this.totalQty,
    required this.totalSold,
  });

  final int rank;
  final String menuId;
  final String menuName;
  final int totalQty;
  final double totalSold;
}

class ReportOrdersByTableEntity {
  const ReportOrdersByTableEntity({
    required this.from,
    required this.to,
    required this.tables,
  });

  final String from;
  final String to;
  final List<OrdersByTableEntryEntity> tables;
}

class OrdersByTableEntryEntity {
  const OrdersByTableEntryEntity({
    required this.rank,
    required this.tableId,
    required this.tableNumber,
    required this.totalOrders,
    required this.totalRevenue,
  });

  final int rank;
  final String tableId;
  final String tableNumber;
  final int totalOrders;
  final double totalRevenue;
}

class ReportDailySummaryEntity {
  const ReportDailySummaryEntity({
    required this.from,
    required this.to,
    required this.summary,
  });

  final String from;
  final String to;
  final List<DailySummaryEntryEntity> summary;
}

class DailySummaryEntryEntity {
  const DailySummaryEntryEntity({
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.avgOrderValue,
  });

  final String date;
  final int totalOrders;
  final double totalRevenue;
  final double avgOrderValue;
}
