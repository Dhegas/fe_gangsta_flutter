import 'package:fe_gangsta_flutter/features/admin/user_management/data/models/user_model.dart';

class UserLocalDataSource {
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();

    return [
      UserModel(
        id: 'u001',
        name: 'Admin Utama',
        email: 'admin@culinaryos.id',
        role: 'admin',
        status: 'active',
        createdAt: DateTime(2023, 1, 15),
        lastLogin: DateTime(now.year, now.month, now.day, 8, 30),
        avatarInitials: 'AU',
      ),
      UserModel(
        id: 'u002',
        name: 'Slamet Riyadi',
        email: 'slamet@baksopal.id',
        role: 'merchant',
        status: 'active',
        createdAt: DateTime(2023, 10, 15),
        lastLogin: DateTime(now.year, now.month, now.day - 1, 20, 10),
        avatarInitials: 'SR',
        tenantId: 't1',
        tenantName: 'Bakso Pak Slamet',
      ),
      UserModel(
        id: 'u003',
        name: 'Budi Santoso',
        email: 'budi@mieayam.id',
        role: 'merchant',
        status: 'active',
        createdAt: DateTime(2024, 1, 10),
        lastLogin: DateTime(now.year, now.month, now.day - 2, 18, 45),
        avatarInitials: 'BS',
        tenantId: 't2',
        tenantName: 'Mie Ayam Jakarta',
      ),
      UserModel(
        id: 'u004',
        name: 'Haji Sulaiman',
        email: 'haji@sototawi.id',
        role: 'merchant',
        status: 'inactive',
        createdAt: DateTime(2022, 5, 20),
        lastLogin: DateTime(now.year, now.month - 2, 10),
        avatarInitials: 'HS',
        tenantId: 't3',
        tenantName: 'Soto Betawi Bang Haji',
      ),
      UserModel(
        id: 'u005',
        name: 'Wati Susilowati',
        email: 'wati@geprekmercon.id',
        role: 'merchant',
        status: 'active',
        createdAt: DateTime(2024, 3, 5),
        lastLogin: DateTime(now.year, now.month, now.day, 12, 0),
        avatarInitials: 'WS',
        tenantId: 't4',
        tenantName: 'Ayam Geprek Mercon',
      ),
      UserModel(
        id: 'u006',
        name: 'Rizky Staf Kasir',
        email: 'rizky@baksopal.id',
        role: 'staff',
        status: 'active',
        createdAt: DateTime(2024, 6, 20),
        lastLogin: DateTime(now.year, now.month, now.day, 11, 30),
        avatarInitials: 'RK',
        tenantId: 't1',
        tenantName: 'Bakso Pak Slamet',
      ),
      UserModel(
        id: 'u007',
        name: 'Dewi Admin Ops',
        email: 'dewi@culinaryos.id',
        role: 'admin',
        status: 'active',
        createdAt: DateTime(2023, 7, 1),
        lastLogin: DateTime(now.year, now.month, now.day - 1, 9, 0),
        avatarInitials: 'DO',
      ),
      UserModel(
        id: 'u008',
        name: 'Eko Prasetyo',
        email: 'eko@geprekmercon.id',
        role: 'staff',
        status: 'suspended',
        createdAt: DateTime(2024, 8, 12),
        lastLogin: DateTime(now.year, now.month - 1, 25),
        avatarInitials: 'EP',
        tenantId: 't4',
        tenantName: 'Ayam Geprek Mercon',
      ),
    ];
  }
}
