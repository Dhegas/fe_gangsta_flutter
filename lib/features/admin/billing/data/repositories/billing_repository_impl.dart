import 'package:fe_gangsta_flutter/features/admin/billing/data/datasources/billing_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl(this._dataSource);

  final BillingLocalDataSource _dataSource;

  @override
  Future<List<BillingEntity>> getBillings() async {
    return _dataSource.getBillings();
  }
}
