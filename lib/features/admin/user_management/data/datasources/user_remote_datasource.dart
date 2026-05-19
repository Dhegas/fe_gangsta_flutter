import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<UserModel>> getUsers() async {
    final response = await _apiClient.get('/users');
    
    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['users'] != null) {
        final usersList = data['users'] as List;
        return usersList.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<UserModel> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    // 1. Register the user via public register
    final regBody = {
      'email': email,
      'password': password,
      'fullName': fullName,
    };
    final regResponse = await _apiClient.post('/auth/register', body: regBody);
    
    if (regResponse == null || regResponse is! Map || regResponse['success'] != true) {
      throw ApiException('Gagal mendaftarkan akun baru');
    }

    final regData = regResponse['data'];
    if (regData == null || regData is! Map || regData['user'] == null) {
      throw ApiException('Format respon registrasi dari server tidak valid');
    }

    final createdUserJson = regData['user'] as Map<String, dynamic>;
    final userId = createdUserJson['id'] as String;

    // 2. If the desired role is admin or merchant, update their role!
    // Since default role is CUSTOMER (staff), if they selected merchant or admin, we call update role!
    if (role.toLowerCase() != 'staff') {
      return await updateUser(id: userId, fullName: fullName, email: email, role: role);
    }

    return UserModel.fromJson(createdUserJson);
  }

  Future<UserModel> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    // Map visual roles back to DB roles
    String dbRole = 'CUSTOMER';
    if (role.toLowerCase() == 'admin') {
      dbRole = 'ADMIN';
    } else if (role.toLowerCase() == 'merchant') {
      dbRole = 'PARTNER';
    }

    final body = {
      'fullName': fullName,
      'email': email,
      'role': dbRole,
    };

    final response = await _apiClient.put('/users/$id', body: body);
    
    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['user'] != null) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon dari server tidak sesuai');
  }

  Future<UserModel> toggleActive(String id) async {
    final response = await _apiClient.patch('/users/$id/toggle-active');
    
    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['user'] != null) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon dari server tidak sesuai');
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.delete('/users/$id');
  }
}
