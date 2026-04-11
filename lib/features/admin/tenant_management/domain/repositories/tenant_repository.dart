import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants();
}
