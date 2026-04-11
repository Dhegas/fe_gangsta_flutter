import 'package:fe_gangsta_flutter/features/admin/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._localDataSource);

  final DashboardLocalDataSource _localDataSource;

  @override
  Future<DashboardStatsEntity> getStats() async {
    return await _localDataSource.getStats();
  }
}
