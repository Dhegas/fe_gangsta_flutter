class StoreEntity {
  const StoreEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.logoUrl,
    required this.bannerImageUrl,
    required this.address,
    required this.openHours,
    required this.isOpen,
  });

  final String id;
  final String name;
  final String slug;
  final String logoUrl;
  final String bannerImageUrl;
  final String address;
  final String openHours;
  final bool isOpen;

  String get description => address.isNotEmpty ? address : 'Buka: $openHours';
}
