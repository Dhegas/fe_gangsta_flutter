import 'package:fe_gangsta_flutter/core/network/api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;
  static const String _basePath = '/api/v1';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _client.postJson(
      '$_basePath/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _client.postJson(
      '$_basePath/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );
  }
}
