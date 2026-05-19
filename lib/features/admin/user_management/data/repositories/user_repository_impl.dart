import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final UserLocalDataSource _localDataSource;
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<List<UserEntity>> getUsers() async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.getUsers();
    } else {
      return await _remoteDataSource.getUsers();
    }
  }

  @override
  Future<UserEntity> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
    } else {
      return await _remoteDataSource.createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
    }
  }

  @override
  Future<UserEntity> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.updateUser(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
      );
    } else {
      return await _remoteDataSource.updateUser(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
      );
    }
  }

  @override
  Future<UserEntity> toggleActive(String id) async {
    if (ApiConfig.useMockData) {
      return await _localDataSource.toggleActive(id);
    } else {
      return await _remoteDataSource.toggleActive(id);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    if (ApiConfig.useMockData) {
      await _localDataSource.deleteUser(id);
    } else {
      await _remoteDataSource.deleteUser(id);
    }
  }
}
