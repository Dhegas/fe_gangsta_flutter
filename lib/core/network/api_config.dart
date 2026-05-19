class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'http://localhost:8080';

  static const String baseUrl = String.fromEnvironment(
    'APP_DOMAIN',
    defaultValue: _defaultBaseUrl,
  );

  static String get apiBaseUrl => '$baseUrl/api/v1';

  // Toggle to switch between simulated mock data and live Go backend endpoints
  static const bool useMockData = false;

  // Development bearer token for testing partner scopes
  static const String devToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiUEFSVE5FUiIsInRlbmFudElkIjoiIiwic3ViIjoiNTEzNWI2MjQtOTI0NC00ZGVjLWE1N2UtZmRkYWZiNTZiNzA3IiwiZXhwIjoxNzc5MjAxODMyLCJpYXQiOjE3NzkyMDA5MzJ9.AIEB9zjGCsGA1abkuvkiFoUTcjgn7EJkpCSYEv-0okE';

  // Fallback Tenant ID for scoping requests
  static const String devTenantId = '';

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
