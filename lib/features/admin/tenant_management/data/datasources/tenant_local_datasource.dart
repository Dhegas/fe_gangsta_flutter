import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class TenantLocalDataSource {
  Future<List<TenantModel>> getTenants() async {
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

  Future<TenantModel> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final newId = name.toLowerCase().replaceAll(' ', '-');
    final newStore = UnifiedDummyStore(
      id: newId,
      name: name,
      description: description,
      bannerImageUrl: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200',
      ownerName: 'Lokal Owner',
      status: 'active',
      subscriptionPlan: 'Pro',
      joinDate: DateTime.now(),
    );

    UnifiedDummyStoreData.stores.add(newStore);

    return TenantModel(
      id: newStore.id,
      name: newStore.name,
      ownerName: newStore.ownerName,
      status: newStore.status,
      subscriptionPlan: newStore.subscriptionPlan,
      joinDate: newStore.joinDate,
    );
  }

  Future<void> deleteTenant(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    UnifiedDummyStoreData.stores.removeWhere((store) => store.id == id);
  }
}
