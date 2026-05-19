import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.name,
    required super.ownerName,
    required super.status,
    required super.subscriptionPlan,
    required super.joinDate,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    // Determine status: backend tenant returns status e.g., "active", "inactive"
    final status = json['status'] as String? ?? 'active';

    // Parse join date or default to now
    DateTime parsedJoinDate = DateTime.now();
    if (json['created_at'] != null) {
      parsedJoinDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return TenantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Store',
      ownerName: json['owner_name'] as String? ?? 'Owner Partner',
      status: status,
      subscriptionPlan: json['subscription_plan'] as String? ?? 'Pro',
      joinDate: parsedJoinDate,
    );
  }
}
