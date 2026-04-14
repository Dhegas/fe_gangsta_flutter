import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class TenantLocalDataSource {
  Future<List<TenantModel>> getTenants() async {
    // Simulating delay
    await Future.delayed(const Duration(milliseconds: 800));

    return UnifiedDummyStoreData.stores
        .map(
          (store) => TenantModel(
            id: store.id,
            name: store.name,
            ownerName: store.ownerName,
            status: store.status,
            subscriptionPlan: store.subscriptionPlan,
            joinDate: store.joinDate,
          ),
        )
        .toList();
  }
}
