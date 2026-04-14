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
}
