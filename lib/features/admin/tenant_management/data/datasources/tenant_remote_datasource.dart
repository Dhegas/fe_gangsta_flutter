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
  }
}
