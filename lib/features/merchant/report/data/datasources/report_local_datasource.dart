import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';

abstract class ReportLocalDataSource {
  Future<MerchantReportEntity> getMockReport();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  @override
  Future<MerchantReportEntity> getMockReport() async {
    return MerchantReportEntity(
      revenue: ReportRevenueEntity(
        from: '2026-05-01',
        to: '2026-05-31',
        totalRevenue: 24500000.0,
        totalOrders: 382,
        generatedAt: DateTime.now(),
      ),
      topMenus: const ReportTopMenusEntity(
        from: '2026-05-01',
        to: '2026-05-31',
        menus: [
          TopMenuEntryEntity(
            rank: 1,
            menuId: '1',
            menuName: 'Nasi Goreng Special',
            totalQty: 120,
            totalSold: 3000000.0,
          ),
          TopMenuEntryEntity(
            rank: 2,
            menuId: '2',
            menuName: 'Mie Goreng Seafood',
            totalQty: 95,
            totalSold: 2375000.0,
          ),
          TopMenuEntryEntity(
            rank: 3,
            menuId: '3',
            menuName: 'Es Teh Manis',
            totalQty: 250,
            totalSold: 1250000.0,
          ),
        ],
      ),
      ordersByTable: const ReportOrdersByTableEntity(
        from: '2026-05-01',
        to: '2026-05-31',
        tables: [
          OrdersByTableEntryEntity(
            rank: 1,
            tableId: '1',
            tableNumber: '05',
            totalOrders: 54,
            totalRevenue: 3240000.0,
          ),
          OrdersByTableEntryEntity(
            rank: 2,
            tableId: '2',
            tableNumber: '02',
            totalOrders: 48,
            totalRevenue: 2880000.0,
          ),
          OrdersByTableEntryEntity(
            rank: 3,
            tableId: '3',
            tableNumber: '10',
            totalOrders: 42,
            totalRevenue: 2520000.0,
          ),
        ],
      ),
      dailySummary: const ReportDailySummaryEntity(
        from: '2026-05-01',
        to: '2026-05-31',
        summary: [
          DailySummaryEntryEntity(
            date: '2026-05-20',
            totalOrders: 15,
            totalRevenue: 900000.0,
            avgOrderValue: 60000.0,
          ),
          DailySummaryEntryEntity(
            date: '2026-05-21',
            totalOrders: 18,
            totalRevenue: 1080000.0,
            avgOrderValue: 60000.0,
          ),
          DailySummaryEntryEntity(
            date: '2026-05-22',
            totalOrders: 22,
            totalRevenue: 1320000.0,
            avgOrderValue: 60000.0,
          ),
        ],
      ),
    );
  }
}
