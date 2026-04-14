class TopSpenderEntity {
  const TopSpenderEntity({
    required this.name,
    required this.totalSpent,
    required this.totalOrders,
  });

  final String name;
  final double totalSpent;
  final int totalOrders;
}

class ReportCustomerInsightEntity {
  const ReportCustomerInsightEntity({
    required this.newCustomers,
    required this.returningCustomers,
    required this.topSpenders,
  });

  final int newCustomers;
  final int returningCustomers;
  final List<TopSpenderEntity> topSpenders;
}
