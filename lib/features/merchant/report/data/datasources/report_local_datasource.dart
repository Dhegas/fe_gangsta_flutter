import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_customer_insight_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_financial_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_sales_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_summary_entity.dart';

abstract class ReportLocalDataSource {
  Future<MerchantReportEntity> getMockReport();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  @override
  Future<MerchantReportEntity> getMockReport() async {
    return const MerchantReportEntity(
      summary: ReportSummaryEntity(
        grossRevenue: 24500000,
        netRevenue: 22150000,
        totalOrders: 382,
        averageOrderValue: 64100,
        periodComparisonPercent: 12.3,
        trend: [2.2, 2.5, 2.8, 2.4, 3.1, 3.0, 3.4],
      ),
      sales: ReportSalesEntity(
        salesByTime: SalesByTimeEntity(hourly: 1250000, daily: 8400000, weekly: 43700000, monthly: 168000000),
        paymentMethods: [
          SalesSegmentEntity(label: 'e-Wallet', amount: 8920000, count: 142),
          SalesSegmentEntity(label: 'Transfer Bank', amount: 6210000, count: 96),
          SalesSegmentEntity(label: 'Kartu Kredit', amount: 3840000, count: 57),
          SalesSegmentEntity(label: 'Tunai', amount: 5530000, count: 87),
        ],
        orderStatuses: [
          SalesSegmentEntity(label: 'Berhasil', amount: 21750000, count: 356),
          SalesSegmentEntity(label: 'Dibatalkan', amount: 1490000, count: 19),
          SalesSegmentEntity(label: 'Refund', amount: 1260000, count: 7),
        ],
        channels: [
          SalesSegmentEntity(label: 'Offline Store', amount: 15300000, count: 244),
          SalesSegmentEntity(label: 'Online Delivery', amount: 9200000, count: 138),
        ],
      ),
      financial: ReportFinancialEntity(
        fees: [
          FeeDeductionEntity(label: 'Biaya Platform', amount: 1320000),
          FeeDeductionEntity(label: 'Biaya Pengiriman', amount: 860000),
          FeeDeductionEntity(label: 'Pajak', amount: 170000),
        ],
        payouts: [
          PayoutEntity(dateLabel: '12 Apr 2026', amount: 5250000, status: 'Selesai'),
          PayoutEntity(dateLabel: '13 Apr 2026', amount: 6480000, status: 'Selesai'),
          PayoutEntity(dateLabel: '14 Apr 2026', amount: 5920000, status: 'Dalam Proses'),
        ],
        refundAmount: 1260000,
        refundCount: 7,
      ),
      customerInsight: ReportCustomerInsightEntity(
        newCustomers: 128,
        returningCustomers: 214,
        topSpenders: [
          TopSpenderEntity(name: 'Nadya Putri', totalSpent: 1860000, totalOrders: 12),
          TopSpenderEntity(name: 'Ari Wijaya', totalSpent: 1675000, totalOrders: 10),
          TopSpenderEntity(name: 'Budi Santoso', totalSpent: 1540000, totalOrders: 9),
        ],
      ),
    );
  }
}
