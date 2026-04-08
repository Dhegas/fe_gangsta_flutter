class PaymentMethodEntity {
  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.adminFee,
  });

  final String id;
  final String name;
  final String description;
  final int adminFee;
}
