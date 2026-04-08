import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';

class TenantLocalDataSource {
  Future<List<TenantModel>> getTenants() async {
    // Simulating delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      TenantModel(
        id: 't1',
        name: 'Bakso Pak Slamet',
        ownerName: 'Slamet Riyadi',
        status: 'active',
        subscriptionPlan: 'Pro',
        joinDate: DateTime(2023, 10, 15),
      ),
      TenantModel(
        id: 't2',
        name: 'Mie Ayam Jakarta',
        ownerName: 'Budi Santoso',
        status: 'active',
        subscriptionPlan: 'Basic',
        joinDate: DateTime(2024, 1, 10),
      ),
      TenantModel(
        id: 't3',
        name: 'Soto Betawi Bang Haji',
        ownerName: 'Haji Sulaiman',
        status: 'inactive',
        subscriptionPlan: 'Pro',
        joinDate: DateTime(2022, 5, 20),
      ),
      TenantModel(
        id: 't4',
        name: 'Ayam Geprek Mercon',
        ownerName: 'Wati Susilowati',
        status: 'active',
        subscriptionPlan: 'Enterprise',
        joinDate: DateTime(2024, 3, 5),
      ),
    ];
  }
}
