class TenantEntity {
  const TenantEntity({
    required this.id,
    required this.name,
    required this.partnerName,
    required this.status,
    required this.subscriptionPlan,
    required this.joinDate,
    required this.description,
    required this.logoUrl,
    this.address = '',
    this.phoneNumber = '',
  });

  final String id;
  final String name;
  final String partnerName;
  final String status;
  final String subscriptionPlan;
  final DateTime joinDate;
  final String description;
  final String logoUrl;
  final String address;
  final String phoneNumber;
}
