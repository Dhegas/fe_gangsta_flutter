import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/repositories/table_management_repository.dart';

class TableManagementRepositoryImpl implements TableManagementRepository {
  const TableManagementRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final TableManagementRemoteDataSource remoteDataSource;
  final TableManagementLocalDataSource localDataSource;

  @override
  Future<void> syncTables() async {
    await remoteDataSource.fetchTableSnapshot();
    await localDataSource.cacheTableSnapshot();
  }
}
