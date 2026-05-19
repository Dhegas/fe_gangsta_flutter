import 'package:fe_gangsta_flutter/features/admin/user_management/data/models/user_model.dart';

class UserLocalDataSource {
  static List<UserModel>? _cachedUsers;

  List<UserModel> _getInitialUsers() {
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

  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _cachedUsers ??= _getInitialUsers();
    return _cachedUsers!;
  }

  Future<UserModel> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _cachedUsers ??= _getInitialUsers();

    // Calculate initials
    String initials = 'U';
    if (fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    final newUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: fullName,
      email: email,
      role: role,
      status: 'active',
      createdAt: DateTime.now(),
      lastLogin: null,
      avatarInitials: initials,
    );

    _cachedUsers!.insert(0, newUser); // Insert at beginning of list
    return newUser;
  }

  Future<UserModel> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cachedUsers ??= _getInitialUsers();

    final idx = _cachedUsers!.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final current = _cachedUsers![idx];
      
      // Calculate initials
      String initials = 'U';
      if (fullName.trim().isNotEmpty) {
        final parts = fullName.trim().split(' ');
        if (parts.length >= 2) {
          initials = (parts[0][0] + parts[1][0]).toUpperCase();
        } else {
          initials = parts[0][0].toUpperCase();
        }
      }

      final updated = UserModel(
        id: id,
        name: fullName,
        email: email,
        role: role,
        status: current.status,
        createdAt: current.createdAt,
        lastLogin: current.lastLogin,
        avatarInitials: initials,
        tenantId: current.tenantId,
        tenantName: current.tenantName,
      );
      _cachedUsers![idx] = updated;
      return updated;
    }
    throw Exception('User tidak ditemukan');
  }

  Future<UserModel> toggleActive(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _cachedUsers ??= _getInitialUsers();

    final idx = _cachedUsers!.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final current = _cachedUsers![idx];
      final newStatus = current.status == 'active' ? 'inactive' : 'active';
      final updated = UserModel(
        id: id,
        name: current.name,
        email: current.email,
        role: current.role,
        status: newStatus,
        createdAt: current.createdAt,
        lastLogin: current.lastLogin,
        avatarInitials: current.avatarInitials,
        tenantId: current.tenantId,
        tenantName: current.tenantName,
      );
      _cachedUsers![idx] = updated;
      return updated;
    }
    throw Exception('User tidak ditemukan');
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _cachedUsers ??= _getInitialUsers();
    _cachedUsers!.removeWhere((u) => u.id == id);
  }
}
