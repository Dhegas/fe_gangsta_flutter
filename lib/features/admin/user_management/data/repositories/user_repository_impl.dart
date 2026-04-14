import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);

  final UserLocalDataSource _dataSource;

  @override
  Future<List<UserEntity>> getUsers() async {
    return _dataSource.getUsers();
  }
}
