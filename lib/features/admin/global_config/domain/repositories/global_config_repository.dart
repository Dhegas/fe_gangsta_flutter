import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';

abstract class GlobalConfigRepository {
  Future<GlobalConfigEntity> getConfig();
  Future<void> updateConfig(GlobalConfigEntity config);
}
