class UserProfileEntity {
  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
}
