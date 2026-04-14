class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLogin,
    this.avatarInitials,
    this.tenantId,
    this.tenantName,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'admin' | 'merchant' | 'staff'
  final String status; // 'active' | 'inactive' | 'suspended'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? avatarInitials;
  final String? tenantId;
  final String? tenantName;
}
