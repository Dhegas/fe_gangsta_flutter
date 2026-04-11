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
}
