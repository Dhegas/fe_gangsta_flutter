import 'package:fe_gangsta_flutter/features/admin/global_config/data/datasources/global_config_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/domain/repositories/global_config_repository.dart';

class GlobalConfigRepositoryImpl implements GlobalConfigRepository {
  GlobalConfigRepositoryImpl(this._dataSource);

  final GlobalConfigLocalDataSource _dataSource;

  @override
  Future<GlobalConfigEntity> getConfig() async {
    return _dataSource.getConfig();
  }

  @override
  Future<void> updateConfig(GlobalConfigEntity config) async {
    return _dataSource.updateConfig(config);
  }
}
