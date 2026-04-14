import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';

abstract class BillingRepository {
  Future<List<BillingEntity>> getBillings();
}
