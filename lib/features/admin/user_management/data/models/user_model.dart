import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.status,
    required super.createdAt,
    super.lastLogin,
    super.avatarInitials,
    super.tenantId,
    super.tenantName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String? ?? 'CUSTOMER';
    final isActive = json['isActive'] as bool? ?? json['is_active'] as bool? ?? true;
    final fullName = json['fullName'] as String? ?? json['full_name'] as String? ?? 'Unknown User';

    // Map backend roles to frontend visual roles
    String mappedRole = 'staff';
    if (rawRole.toUpperCase() == 'ADMIN') {
      mappedRole = 'admin';
    } else if (rawRole.toUpperCase() == 'PARTNER') {
      mappedRole = 'merchant';
    }

    // Generate avatar initials from name
    String initials = 'U';
    if (fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      name: fullName,
      email: json['email'] as String? ?? '',
      role: mappedRole,
      status: isActive ? 'active' : 'inactive',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'] as String)
          : null,
      avatarInitials: initials,
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String?,
      tenantName: json['tenantName'] as String? ?? json['tenant_name'] as String?,
    );
  }
}
