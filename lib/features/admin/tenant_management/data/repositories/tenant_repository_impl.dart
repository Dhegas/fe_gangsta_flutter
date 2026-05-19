import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final TenantLocalDataSource _localDataSource;
  final TenantRemoteDataSource _remoteDataSource;

  @override
  Future<List<TenantEntity>> getTenants() async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.getTenants();
    } else {
      return await _remoteDataSource.getTenants();
    }
  }

  @override
  Future<TenantEntity> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.createTenant(
        name: name,
        description: description,
        address: address,
        phoneNumber: phoneNumber,
      );
    } else {
      return await _remoteDataSource.createTenant(
        name: name,
        description: description,
        address: address,
        phoneNumber: phoneNumber,
      );
    }
  }

  @override
  Future<void> deleteTenant(String id) async {
    if (ApiConfig.useMockData) {
      await _localDataSource.deleteTenant(id);
    } else {
      await _remoteDataSource.deleteTenant(id);
    }
  }
}
