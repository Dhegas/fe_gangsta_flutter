import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';

class ReportRevenueModel extends ReportRevenueEntity {
  const ReportRevenueModel({
    required super.from,
    required super.to,
    required super.totalRevenue,
    required super.totalOrders,
    required super.generatedAt,
  });

  factory ReportRevenueModel.fromJson(Map<String, dynamic> json) {
    return ReportRevenueModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String)
          : DateTime.now(),
    );
  }
}

class ReportTopMenusModel extends ReportTopMenusEntity {
  const ReportTopMenusModel({
    required super.from,
    required super.to,
    required super.menus,
  });

  factory ReportTopMenusModel.fromJson(Map<String, dynamic> json) {
    return ReportTopMenusModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      menus: (json['menus'] as List<dynamic>?)
              ?.map((e) => TopMenuEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TopMenuEntryModel extends TopMenuEntryEntity {
  const TopMenuEntryModel({
    required super.rank,
    required super.menuId,
    required super.menuName,
    required super.totalQty,
    required super.totalSold,
  });

  factory TopMenuEntryModel.fromJson(Map<String, dynamic> json) {
    return TopMenuEntryModel(
      rank: json['rank'] as int? ?? 0,
      menuId: json['menu_id'] as String? ?? '',
      menuName: json['menu_name'] as String? ?? '',
      totalQty: json['total_qty'] as int? ?? 0,
      totalSold: (json['total_sold'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReportOrdersByTableModel extends ReportOrdersByTableEntity {
  const ReportOrdersByTableModel({
    required super.from,
    required super.to,
    required super.tables,
  });

  factory ReportOrdersByTableModel.fromJson(Map<String, dynamic> json) {
    return ReportOrdersByTableModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      tables: (json['tables'] as List<dynamic>?)
              ?.map((e) => OrdersByTableEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrdersByTableEntryModel extends OrdersByTableEntryEntity {
  const OrdersByTableEntryModel({
    required super.rank,
    required super.tableId,
    required super.tableNumber,
    required super.totalOrders,
    required super.totalRevenue,
  });

  factory OrdersByTableEntryModel.fromJson(Map<String, dynamic> json) {
    return OrdersByTableEntryModel(
      rank: json['rank'] as int? ?? 0,
      tableId: json['table_id'] as String? ?? '',
      tableNumber: json['table_number'] as String? ?? '',
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReportDailySummaryModel extends ReportDailySummaryEntity {
  const ReportDailySummaryModel({
    required super.from,
    required super.to,
    required super.summary,
  });

  factory ReportDailySummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportDailySummaryModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      summary: (json['summary'] as List<dynamic>?)
              ?.map((e) => DailySummaryEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DailySummaryEntryModel extends DailySummaryEntryEntity {
  const DailySummaryEntryModel({
    required super.date,
    required super.totalOrders,
    required super.totalRevenue,
    required super.avgOrderValue,
  });

  factory DailySummaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryEntryModel(
      date: json['date'] as String? ?? '',
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
