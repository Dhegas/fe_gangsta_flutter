import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';

class BillingModel extends BillingEntity {
  const BillingModel({
    required super.id,
    required super.tenantId,
    required super.tenantName,
    required super.plan,
    required super.amount,
    required super.status,
    required super.dueDate,
    required super.paidAt,
    required super.invoiceNumber,
  });
}
