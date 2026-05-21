class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.avatarInitials,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'CUSTOMER' | 'PARTNER' | 'ADMIN'
  final bool isActive;
  final String? avatarInitials;
}
