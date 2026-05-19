import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class TenantListResult {
  const TenantListResult({
    required this.tenants,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  final List<TenantEntity> tenants;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
}

abstract class TenantRepository {
  Future<TenantListResult> getTenants({int page = 1, int limit = 10});
}
