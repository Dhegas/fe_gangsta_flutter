import 'dart:convert';

import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    required this.client,
    this.getAccessToken,
    this.defaultHeaders = const {},
  });

  final http.Client client;
  final String? Function()? getAccessToken;
  final Map<String, String> defaultHeaders;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final response = await client.get(
      ApiConfig.buildUri(path, query: query),
      headers: _buildHeaders(headers),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final response = await client.post(
      ApiConfig.buildUri(path, query: query),
      headers: _buildHeaders(headers),
      body: body == null ? null : jsonEncode(body),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final response = await client.patch(
      ApiConfig.buildUri(path, query: query),
      headers: _buildHeaders(headers),
      body: body == null ? null : jsonEncode(body),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final request = http.Request(
      'DELETE',
      ApiConfig.buildUri(path, query: query),
    )
      ..headers.addAll(_buildHeaders(headers));

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decodeJsonResponse(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final merged = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...defaultHeaders,
      ...?headers,
    };

    final token = getAccessToken?.call();
    if (token != null && token.isNotEmpty && !merged.containsKey('Authorization')) {
      merged['Authorization'] = 'Bearer $token';
    }

    return merged;
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'Request failed',
        statusCode: response.statusCode,
        rawBody: response.body,
      );
    }

    if (response.body.isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List) {
      return <String, dynamic>{'data': decoded};
    }

    return <String, dynamic>{'data': decoded};
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    required this.rawBody,
  });

  final String message;
  final int statusCode;
  final String rawBody;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, rawBody: $rawBody)';
  }
}
