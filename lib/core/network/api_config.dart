class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl =
      'http://localhost:8080';

  static const String baseUrl = String.fromEnvironment(
    'APP_DOMAIN',
    defaultValue: _defaultBaseUrl,
  );

  static String? token;

  static Uri buildUri(
    String path, {
    Map<String, dynamic>? query,
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: _normalizeQuery(query),
    );
  }

  static Map<String, String>? _normalizeQuery(Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) {
      return null;
    }

    return query.map((key, value) => MapEntry(key, value.toString()));
  }
}
