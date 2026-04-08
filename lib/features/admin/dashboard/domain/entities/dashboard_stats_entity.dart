class DashboardStatsEntity {
  const DashboardStatsEntity({
    required this.totalTenants,
    required this.activeMemberships,
    required this.totalRevenue,
    required this.newTenantsThisMonth,
  });

  final int totalTenants;
  final int activeMemberships;
  final int totalRevenue;
  final int newTenantsThisMonth;
}
