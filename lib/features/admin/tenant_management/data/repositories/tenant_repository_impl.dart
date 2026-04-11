import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._localDataSource);

  final TenantLocalDataSource _localDataSource;

  @override
  Future<List<TenantEntity>> getTenants() async {
    return await _localDataSource.getTenants();
  }
}
