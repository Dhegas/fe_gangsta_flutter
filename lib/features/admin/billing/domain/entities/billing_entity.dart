class BillingEntity {
  const BillingEntity({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.plan,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.paidAt,
    required this.invoiceNumber,
  });

  final String id;
  final String tenantId;
  final String tenantName;
  final String plan;
  final int amount;
  final String status; // 'paid' | 'unpaid' | 'overdue' | 'pending'
  final DateTime dueDate;
  final DateTime? paidAt;
  final String invoiceNumber;
}
