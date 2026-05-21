import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_gangsta_flutter/core/network/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.apiBaseUrl;

  final String _baseUrl;
  static String? activeToken;
  static String? activeTenantId;
  static String? activeTenantName;

  Map<String, String> _buildHeaders({String? tenantId}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = activeToken ?? ApiConfig.devToken;
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final currentTenantId = tenantId ?? activeTenantId ?? ApiConfig.devTenantId;
    if (currentTenantId.isNotEmpty) {
      headers['X-Tenant-ID'] = currentTenantId;
    }

    return headers;
  }

  Future<dynamic> get(String path, {String? tenantId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.get(uri, headers: _buildHeaders(tenantId: tenantId));
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(tenantId: tenantId),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.put(
        uri,
        headers: _buildHeaders(tenantId: tenantId),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, String? tenantId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.patch(
        uri,
        headers: _buildHeaders(tenantId: tenantId),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String path, {String? tenantId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.delete(uri, headers: _buildHeaders(tenantId: tenantId));
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
