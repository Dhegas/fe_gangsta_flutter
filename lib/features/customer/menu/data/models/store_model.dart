import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.logoUrl,
    required super.bannerImageUrl,
    required super.address,
    required super.openHours,
    required super.isOpen,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Store',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      bannerImageUrl: json['bannerUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
      openHours: json['openHours'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }
}
