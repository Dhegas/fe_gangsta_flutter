import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_create_entity.dart';

class TenantCreateRequestModel extends TenantCreateEntity {
  const TenantCreateRequestModel({
    required super.userId,
    required super.name,
    super.status,
    super.description,
    super.address,
    super.phoneNumber,
    super.openHours,
    super.logoUrl,
    super.bannerUrl,
  });

  factory TenantCreateRequestModel.fromEntity(TenantCreateEntity entity) {
    return TenantCreateRequestModel(
      userId: entity.userId,
      name: entity.name,
      status: entity.status,
      description: entity.description,
      address: entity.address,
      phoneNumber: entity.phoneNumber,
      openHours: entity.openHours,
      logoUrl: entity.logoUrl,
      bannerUrl: entity.bannerUrl,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'user_id': userId.trim(),
      'name': name.trim(),
    };

    _writeIfNotEmpty(data, 'status', status);
    _writeIfNotEmpty(data, 'description', description);
    _writeIfNotEmpty(data, 'address', address);
    _writeIfNotEmpty(data, 'phone_number', phoneNumber);
    _writeIfNotEmpty(data, 'open_hours', openHours);
    _writeIfNotEmpty(data, 'logo_url', logoUrl);
    _writeIfNotEmpty(data, 'banner_url', bannerUrl);

    return data;
  }
}

void _writeIfNotEmpty(Map<String, dynamic> data, String key, String? value) {
  final trimmed = value?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    data[key] = trimmed;
  }
}
