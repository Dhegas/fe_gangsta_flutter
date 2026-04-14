import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/repositories/table_management_repository.dart';

class GetTableManagement {
  const GetTableManagement(this._repository);

  final TableManagementRepository _repository;

  Future<void> call() {
    return _repository.syncTables();
  }
}
