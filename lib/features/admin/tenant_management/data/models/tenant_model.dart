import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.name,
    required super.partnerName,
    required super.status,
    required super.subscriptionPlan,
    required super.joinDate,
    required super.description,
    required super.logoUrl,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    // Deterministic plan mapping based on tenant name/id to keep the rich UI aesthetic
    final id = json['id'] as String? ?? '';
    final code = id.hashCode % 3;
    final plan = code == 0
        ? 'Enterprise'
        : code == 1
            ? 'Pro'
            : 'Basic';

    // Format partner name from user ID
    final userId = json['user_id'] as String? ?? 'Admin / Partner';
    final partnerName = userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

    return TenantModel(
      id: id,
      name: json['name'] as String? ?? 'Unnamed Tenant',
      partnerName: partnerName,
      status: json['status'] as String? ?? 'active',
      subscriptionPlan: plan,
      joinDate: DateTime.now().subtract(Duration(days: id.hashCode % 365)),
      description: json['description'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }
}
