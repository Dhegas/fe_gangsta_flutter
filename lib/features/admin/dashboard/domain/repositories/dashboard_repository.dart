import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStatsEntity> getStats();
}
