import 'package:fe_gangsta_flutter/features/admin/dashboard/data/models/dashboard_stats_model.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class DashboardLocalDataSource {
  Future<DashboardStatsModel> getStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final totalTenants = UnifiedDummyStoreData.stores.length;
    final activeMemberships = UnifiedDummyStoreData.stores
        .where((store) => store.status == 'active')
        .length;

    final now = DateTime.now();
    final newTenantsThisMonth = UnifiedDummyStoreData.stores
        .where(
          (store) =>
              store.joinDate.year == now.year &&
              store.joinDate.month == now.month,
        )
        .length;

    final totalRevenue = UnifiedDummyStoreData.stores.fold<int>(
      0,
      (sum, store) => sum + _planPrice(store.subscriptionPlan),
    );

    return DashboardStatsModel(
      totalTenants: totalTenants,
      activeMemberships: activeMemberships,
      totalRevenue: totalRevenue,
      newTenantsThisMonth: newTenantsThisMonth,
    );
  }

  int _planPrice(String subscriptionPlan) {
    switch (subscriptionPlan.toLowerCase()) {
      case 'enterprise':
        return 349000;
      case 'pro':
        return 199000;
      default:
        return 99000;
    }
  }
}
