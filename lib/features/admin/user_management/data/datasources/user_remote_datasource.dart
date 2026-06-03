import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/models/user_model.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/repositories/user_repository.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Get all users. Optionally filter by [role] (e.g. 'CUSTOMER' or 'PARTNER'), [page], and [limit].
  Future<UserListResult> getUsers({String? role, int? page, int? limit}) async {
    final params = <String>[];
    if (role != null) params.add('role=$role');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final response = await _apiClient.get('/api/v1/admin/users$query');

    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map) {
        final usersList = data['users'] as List?;
        final pagination = data['pagination'] as Map<String, dynamic>?;

        final users = usersList != null
            ? usersList
                .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : <UserModel>[];

        final resPage = pagination?['page'] as int? ?? page ?? 1;
        final resLimit = pagination?['limit'] as int? ?? limit ?? 10;
        final totalItems = pagination?['total_items'] as int? ?? users.length;
        final totalPages = pagination?['total_pages'] as int? ?? 1;

        return UserListResult(
          users: users,
          page: resPage,
          limit: resLimit,
          totalItems: totalItems,
          totalPages: totalPages,
        );
      }
    }
    return UserListResult(
      users: const [],
      page: page ?? 1,
      limit: limit ?? 10,
      totalItems: 0,
      totalPages: 1,
    );
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
