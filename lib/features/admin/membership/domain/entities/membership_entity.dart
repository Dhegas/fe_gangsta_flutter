class MembershipEntity {
  const MembershipEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.billingCycle,
    required this.features,
    required this.isPopular,
  });

  final String id;
  final String name;
  final int price;
  final String billingCycle;
  final List<String> features;
  final bool isPopular;
}
