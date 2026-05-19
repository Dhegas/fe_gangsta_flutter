import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._remoteDataSource);

  final TenantRemoteDataSource _remoteDataSource;

  @override
  Future<TenantListResult> getTenants({int page = 1, int limit = 10}) async {
    return await _remoteDataSource.getTenants(page: page, limit: limit);
  }
}
