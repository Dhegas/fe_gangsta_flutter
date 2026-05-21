import 'package:fe_gangsta_flutter/core/network/api_client.dart' as net;
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_create_request_model.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

// Admin remote data source
class TenantRemoteDataSource {
  TenantRemoteDataSource(this._client);

  final net.ApiClient _client;

  Future<TenantListResult> getTenants({int page = 1, int limit = 10}) async {
    final response = await _client.getJson(
      '/api/v1/admin/tenants',
      query: {'page': page, 'limit': limit},
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final tenantsList = data['tenants'] as List?;
      final pagination = data['pagination'] as Map<String, dynamic>?;

      final tenants = tenantsList != null
          ? tenantsList
                .map(
                  (json) => TenantModel.fromJson(json as Map<String, dynamic>),
                )
                .toList()
          : <TenantModel>[];

      final resPage = pagination?['page'] as int? ?? page;
      final resLimit = pagination?['limit'] as int? ?? limit;
      final totalItems = pagination?['total_items'] as int? ?? tenants.length;
      final totalPages = pagination?['total_pages'] as int? ?? 1;

      return TenantListResult(
        tenants: tenants,
        page: resPage,
        limit: resLimit,
        totalItems: totalItems,
        totalPages: totalPages,
      );
    }
    return TenantListResult(
      tenants: const [],
      page: page,
      limit: limit,
      totalItems: 0,
      totalPages: 1,
    );
  }

  Future<TenantModel> createTenant(TenantCreateRequestModel request) async {
    final response = await _client.postJson(
      '/api/v1/admin/tenants',
      body: request.toJson(),
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final tenantJson = data['tenant'] is Map<String, dynamic>
          ? data['tenant'] as Map<String, dynamic>
          : data;
      return TenantModel.fromJson(tenantJson);
    }
    throw const net.ApiException(
      message: 'Format respon dari server tidak sesuai',
      statusCode: 500,
      rawBody: '',
    );
  }

  Future<void> deleteTenant(String id) async {
    await _client.deleteJson('/api/v1/admin/tenants/$id');
  }
}
