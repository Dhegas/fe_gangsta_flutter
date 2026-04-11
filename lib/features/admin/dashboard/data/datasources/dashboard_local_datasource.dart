import 'package:fe_gangsta_flutter/features/admin/dashboard/data/models/dashboard_stats_model.dart';

class DashboardLocalDataSource {
  Future<DashboardStatsModel> getStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return const DashboardStatsModel(
      totalTenants: 124,
      activeMemberships: 112,
      totalRevenue: 28500000,
      newTenantsThisMonth: 18,
    );
  }
}
