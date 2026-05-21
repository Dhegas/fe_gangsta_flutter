import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

abstract class UserRepository {
  /// Fetch all users. If [role] is provided (e.g. 'CUSTOMER' or 'PARTNER'),
  /// filters by role on the backend.
  Future<List<UserEntity>> getUsers({String? role});

  Future<UserEntity> getUserDetail(String id);

  Future<UserEntity> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  Future<UserEntity> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  });

  Future<UserEntity> toggleActive(String id);

  Future<void> deleteUser(String id);
}
