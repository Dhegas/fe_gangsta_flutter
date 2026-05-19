<<<<<<< HEAD
import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';

class TenantRemoteDataSource {
  TenantRemoteDataSource(this._client);

  final ApiClient _client;

  Future<TenantListResult> getTenants({int page = 1, int limit = 10}) async {
    final response = await _client.getJson(
      '/api/v1/admin/tenants',
      query: {
        'page': page,
        'limit': limit,
      },
    );
    
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final tenantsList = data['tenants'] as List?;
      final pagination = data['pagination'] as Map<String, dynamic>?;

      final tenants = tenantsList != null
          ? tenantsList
              .map((json) => TenantModel.fromJson(json as Map<String, dynamic>))
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
=======
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';

class TenantRemoteDataSource {
  TenantRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TenantModel>> getTenants() async {
    final response = await _apiClient.get('/partner/tenants');
    
    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['tenants'] != null) {
        final tenantsList = data['tenants'] as List;
        return tenantsList.map((e) => TenantModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<TenantModel> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    final body = {
      'name': name,
      'description': description,
      'address': address,
      'phone_number': phoneNumber,
    };

    final response = await _apiClient.post('/partner/tenants', body: body);
    
    if (response != null && response is Map && response['success'] == true) {
      final data = response['data'];
      if (data != null && data is Map && data['tenant'] != null) {
        return TenantModel.fromJson(data['tenant'] as Map<String, dynamic>);
      }
    }
    throw ApiException('Format respon dari server tidak sesuai');
  }

  Future<void> deleteTenant(String id) async {
    await _apiClient.delete('/partner/tenants/$id');
>>>>>>> dev-renata
  }
}
