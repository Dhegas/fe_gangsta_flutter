class TenantEntity {
  const TenantEntity({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.status,
    required this.subscriptionPlan,
    required this.joinDate,
  });

  final String id;
  final String name;
  final String ownerName;
  final String status;
  final String subscriptionPlan;
  final DateTime joinDate;
}
