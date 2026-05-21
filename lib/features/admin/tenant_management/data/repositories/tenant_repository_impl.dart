import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_create_request_model.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_create_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._remoteDataSource);

  final TenantRemoteDataSource _remoteDataSource;

  @override
  Future<TenantListResult> getTenants({int page = 1, int limit = 10}) async {
    return await _remoteDataSource.getTenants(page: page, limit: limit);
  }

  @override
  Future<TenantEntity> createTenant(TenantCreateEntity payload) async {
    final request = TenantCreateRequestModel.fromEntity(payload);
    return await _remoteDataSource.createTenant(request);
  }

  @override
  Future<void> deleteTenant(String id) async {
    await _remoteDataSource.deleteTenant(id);
  }
}
