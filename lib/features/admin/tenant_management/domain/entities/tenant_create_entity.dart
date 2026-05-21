class TenantCreateEntity {
  const TenantCreateEntity({
    required this.userId,
    required this.name,
    this.status,
    this.description,
    this.address,
    this.phoneNumber,
    this.openHours,
    this.logoUrl,
    this.bannerUrl,
  });

  final String userId;
  final String name;
  final String? status;
  final String? description;
  final String? address;
  final String? phoneNumber;
  final String? openHours;
  final String? logoUrl;
  final String? bannerUrl;
}
