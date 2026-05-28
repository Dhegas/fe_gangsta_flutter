import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.avatarInitials,
    this.tenants,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'CUSTOMER' | 'PARTNER' | 'ADMIN'
  final bool isActive;
  final String? avatarInitials;
  final List<TenantEntity>? tenants;

  String get status => isActive ? 'active' : 'inactive';
}

