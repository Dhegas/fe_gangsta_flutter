import 'package:fe_gangsta_flutter/features/merchant/pos/data/datasources/pos_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  PosRepositoryImpl(this._localDataSource);

  final PosLocalDataSource _localDataSource;

  @override
  Future<List<PosCategory>> getCategories() {
    return _localDataSource.getCategories();
  }

  @override
  Future<List<PosMenuItemEntity>> getMenuItems() {
    return _localDataSource.getMenuItems();
  }

  @override
  Future<String> getMerchantName() {
    return _localDataSource.getMerchantName();
  }

  @override
  Future<String> getMerchantRoleLabel() {
    return _localDataSource.getMerchantRoleLabel();
  }

  @override
  Future<List<String>> getTableLabels() {
    return _localDataSource.getTableLabels();
  }
}
