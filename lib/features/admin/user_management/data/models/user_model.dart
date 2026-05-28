import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    super.avatarInitials,
    super.tenants,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'CUSTOMER';
    final isActive = json['isActive'] as bool? ?? json['is_active'] as bool? ?? true;
    final fullName = json['fullName'] as String? ?? json['full_name'] as String? ?? 'Unknown User';

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

    final tenants = (json['tenants'] as List?)
        ?.map((e) {
          final tenantMap = Map<String, dynamic>.from(e as Map);
          tenantMap['owner_name'] = fullName;
          return TenantModel.fromJson(tenantMap);
        })
        .toList();

    return UserModel(
      id: json['id'] as String? ?? '',
      name: fullName,
      email: json['email'] as String? ?? '',
      role: role.toUpperCase(),
      isActive: isActive,
      avatarInitials: initials,
      tenants: tenants,
    );
  }
}

