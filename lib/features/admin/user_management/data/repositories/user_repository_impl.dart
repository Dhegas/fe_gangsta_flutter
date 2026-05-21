import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<List<UserEntity>> getUsers({String? role}) async {
    return await _remoteDataSource.getUsers(role: role);
  }

  @override
  Future<UserEntity> getUserDetail(String id) async {
    return await _remoteDataSource.getUserDetail(id);
  }

  @override
  Future<UserEntity> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    return await _remoteDataSource.createUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<UserEntity> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    return await _remoteDataSource.updateUser(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
    );
  }

  @override
  Future<UserEntity> toggleActive(String id) async {
    return await _remoteDataSource.toggleActive(id);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _remoteDataSource.deleteUser(id);
  }
}
