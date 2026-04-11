import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalTenants,
    required super.activeMemberships,
    required super.totalRevenue,
    required super.newTenantsThisMonth,
  });
}
