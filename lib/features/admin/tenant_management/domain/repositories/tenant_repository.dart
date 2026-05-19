import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants();
  
  Future<TenantEntity> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  });

  Future<void> deleteTenant(String id);
}
