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
  Future<TenantListResult> getTenants({int page = 1, int limit = 10}) async {
    if (ApiConfig.useMockData) {
      final localTenants = await _localDataSource.getTenants();
      
      // Page partition calculation
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginated = localTenants.sublist(
        startIndex.clamp(0, localTenants.length),
        endIndex.clamp(0, localTenants.length),
      );

      return TenantListResult(
        tenants: paginated,
        page: page,
        limit: limit,
        totalItems: localTenants.length,
        totalPages: (localTenants.length / limit).ceil(),
      );
    } else {
      return await _remoteDataSource.getTenants(page: page, limit: limit);
    }
  }

  @override
  Future<TenantEntity> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    return await _remoteDataSource.createTenant(
      name: name,
      description: description,
      address: address,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> deleteTenant(String id) async {
    await _remoteDataSource.deleteTenant(id);
  }
}
