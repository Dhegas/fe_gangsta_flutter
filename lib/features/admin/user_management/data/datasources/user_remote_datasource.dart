import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Get all users. Optionally filter by [role] (e.g. 'CUSTOMER' or 'PARTNER').
  Future<List<UserModel>> getUsers({String? role}) async {
    final query = role != null ? '?role=$role' : '';
    final response = await _apiClient.get('/api/v1/admin/users$query');

    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['users'] != null) {
        final usersList = data['users'] as List;
        return usersList
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<UserModel> getUserDetail(String id) async {
    final response = await _apiClient.get('/api/v1/admin/users/$id');

    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['user'] != null) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon detail user dari server tidak sesuai');
  }

  Future<UserModel> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
    };
    final response = await _apiClient.post('/api/v1/auth/register', body: body);

    if (response == null || response is! Map || response['success'] != true) {
      throw ApiException('Gagal mendaftarkan akun baru');
    }

    final data = response['data'];
    if (data == null || data is! Map || data['user'] == null) {
      throw ApiException('Format respon registrasi dari server tidak valid');
    }

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    final body = {
      'fullName': fullName,
      'email': email,
      'role': role,
    };

    final response = await _apiClient.put('/api/v1/users/$id', body: body);

    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['user'] != null) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon dari server tidak sesuai');
  }

  Future<UserModel> toggleActive(String id) async {
    final response = await _apiClient.patch('/api/v1/users/$id/toggle-active');

    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['user'] != null) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon dari server tidak sesuai');
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.delete('/api/v1/users/$id');
  }
}
