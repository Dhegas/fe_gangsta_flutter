import 'dart:convert';

import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:fe_gangsta_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.login(
        email: email,
        password: password,
      );

      return _resolveRole(response);
    } on ApiException catch (error) {
      throw AuthFailure(_mapAuthError(error, isRegister: false));
    }
  }

  @override
  Future<UserRole> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      return _resolveRole(response, fallbackRole: UserRole.customer);
    } on ApiException catch (error) {
      throw AuthFailure(_mapAuthError(error, isRegister: true));
    }
  }

  String _mapAuthError(ApiException error, {required bool isRegister}) {
    final message = _extractMessage(error.rawBody);
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }

    switch (error.statusCode) {
      case 0:
        return 'Tidak bisa terhubung ke server. Periksa koneksi internet.';
      case 401:
      case 403:
        return 'Email atau password salah.';
      case 409:
        return isRegister ? 'Email sudah terdaftar.' : 'Akun sudah terdaftar.';
      case 400:
        return 'Data yang dikirim belum valid.';
      default:
        return 'Login gagal (status: ${error.statusCode}). Coba lagi nanti.';
    }
  }

  String? _extractMessage(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final directMessage = decoded['message'];
        if (directMessage is String) {
          return directMessage;
        }

        final errorField = decoded['error'];
        if (errorField is String) {
          return errorField;
        }
        if (errorField is Map && errorField['message'] is String) {
          return errorField['message'] as String;
        }

        final dataField = decoded['data'];
        if (dataField is Map && dataField['message'] is String) {
          return dataField['message'] as String;
        }
      }
    } catch (_) {
      return rawBody;
    }

    return null;
  }

  UserRole _resolveRole(
    Map<String, dynamic> response, {
    UserRole? fallbackRole,
  }) {
    final rawRole = _extractRoleValue(response);
    final parsedRole = parseUserRole(rawRole);

    if (parsedRole != null) {
      return parsedRole;
    }

    if (fallbackRole != null) {
      return fallbackRole;
    }

    throw const AuthFailure('Role user tidak ditemukan dari response.');
  }

  String? _extractRoleValue(Map<String, dynamic> response) {
    final directRole = response['role'];
    if (directRole is String) {
      return directRole;
    }

    final data = response['data'];
    final roleFromData = _extractRoleFromValue(data);
    if (roleFromData != null) {
      return roleFromData;
    }

    return _extractRoleFromValue(response['user']);
  }

  String? _extractRoleFromValue(Object? value) {
    if (value is String) {
      return value;
    }

    if (value is Map) {
      final role = value['role'];
      if (role is String) {
        return role;
      }

      final nestedUser = value['user'];
      if (nestedUser is Map && nestedUser['role'] is String) {
        return nestedUser['role'] as String;
      }

      final account = value['account'];
      if (account is Map && account['role'] is String) {
        return account['role'] as String;
      }
    }

    return null;
  }
}
