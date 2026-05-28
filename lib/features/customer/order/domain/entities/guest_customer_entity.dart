class GuestCustomerEntity {
  const GuestCustomerEntity({
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.password,
  });

  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? password;
}
