import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/entities/dashboard_stats_entity.dart';

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.stats,
  });

  final bool isLoading;
  final DashboardStatsEntity? stats;

  DashboardState copyWith({
    bool? isLoading,
    DashboardStatsEntity? stats,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
    );
  }
}
