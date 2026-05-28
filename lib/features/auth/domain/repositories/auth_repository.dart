import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_profile_entity.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<UserProfileEntity> getProfile();

  Future<UserRole> login({
    required String email,
    required String password,
  });

  Future<UserRole> register({
    required String fullName,
    required String email,
    required String password,
    String? role,
  });
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() {
    return 'AuthFailure(message: $message)';
  }
}
