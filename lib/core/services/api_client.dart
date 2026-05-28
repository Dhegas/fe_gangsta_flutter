import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/core/services/storage_service.dart';
import 'package:fe_gangsta_flutter/main.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final String _baseUrl;
  static String? activeToken;
  static String? activeTenantId;
  static String? activeTenantName;

  static bool _isRefreshing = false;

  Map<String, String> _buildHeaders({String? tenantId}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = activeToken ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final currentTenantId = tenantId ?? activeTenantId ?? '';
    if (currentTenantId.isNotEmpty) {
      headers['X-Tenant-ID'] = currentTenantId;
    }

    return headers;
  }

  static Future<bool> performTokenRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = AuthState.activeRefreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        AuthState.logout();
        return false;
      }

      final refreshUri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/refresh');
      final response = await http.post(
        refreshUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dataMap = jsonDecode(response.body);
        if (dataMap['success'] == true) {
          final data = dataMap['data'];
          if (data != null && data is Map) {
            final newAccessToken = data['accessToken'] as String?;
            final newRefreshToken = data['refreshToken'] as String?;
            if (newAccessToken != null && newRefreshToken != null) {
              activeToken = newAccessToken;
              ApiConfig.token = newAccessToken;
              AuthState.activeRefreshToken = newRefreshToken;

              final role = AuthState.roleNotifier.value;
              if (role != null) {
                await StorageService.saveAuth(
                  token: newAccessToken,
                  refreshToken: newRefreshToken,
                  role: role,
                );
              }
              return true;
            }
          }
        }
      }

      AuthState.logout();
      return false;
    } catch (_) {
      AuthState.logout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() requestFn, {
    int retryCount = 0,
  }) async {
    final response = await requestFn();

    if (response.statusCode == 401 && retryCount < 1) {
      final success = await performTokenRefresh();
      if (success) {
        return _sendWithRetry(requestFn, retryCount: retryCount + 1);
      }
    }

    return response;
  }

  Future<dynamic> get(String path, {String? tenantId}) async {
    try {
      final response = await _sendWithRetry(() {
        final uri = Uri.parse('$_baseUrl$path');
        return http.get(uri, headers: _buildHeaders(tenantId: tenantId));
      });
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    try {
      final response = await _sendWithRetry(() {
        final uri = Uri.parse('$_baseUrl$path');
        return http.post(
          uri,
          headers: _buildHeaders(tenantId: tenantId),
          body: body != null ? jsonEncode(body) : null,
        );
      });
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    try {
      final response = await _sendWithRetry(() {
        final uri = Uri.parse('$_baseUrl$path');
        return http.put(
          uri,
          headers: _buildHeaders(tenantId: tenantId),
          body: body != null ? jsonEncode(body) : null,
        );
      });
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    try {
      final response = await _sendWithRetry(() {
        final uri = Uri.parse('$_baseUrl$path');
        return http.patch(
          uri,
          headers: _buildHeaders(tenantId: tenantId),
          body: body != null ? jsonEncode(body) : null,
        );
      });
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String path, {String? tenantId}) async {
    try {
      final response = await _sendWithRetry(() {
        final uri = Uri.parse('$_baseUrl$path');
        return http.delete(uri, headers: _buildHeaders(tenantId: tenantId));
      });
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = response.body;
    dynamic jsonResponse;
    try {
      jsonResponse = body.isNotEmpty ? jsonDecode(body) : null;
    } catch (_) {
      jsonResponse = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else {
      if (response.statusCode == 401) {
        AuthState.logout();
      }
      String errorMessage = 'Terjadi kesalahan sistem';
      if (jsonResponse != null && jsonResponse is Map) {
        if (jsonResponse['message'] != null) {
          errorMessage = jsonResponse['message'].toString();
        } else if (jsonResponse['error'] != null) {
          errorMessage = jsonResponse['error'].toString();
        }
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      throw error;
    }
    throw ApiException('Koneksi internet gagal atau server backend tidak merespon: ${error.toString()}');
  }
}
