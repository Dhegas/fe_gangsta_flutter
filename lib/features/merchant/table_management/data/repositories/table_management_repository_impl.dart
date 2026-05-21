import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
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
    await localDataSource.cacheTableSnapshot();
  }

  @override
  Future<List<TableEntity>> getTables() async {
    final models = await remoteDataSource.fetchTables();
    final statusFutures = models.map((m) => remoteDataSource.fetchTableStatus(m.id)).toList();
    final statuses = await Future.wait(statusFutures);

    final List<TableEntity> entities = [];
    for (int i = 0; i < models.length; i++) {
      entities.add(models[i].toEntity().copyWith(status: statuses[i]));
    }
    return entities;
  }

  @override
  Future<TableEntity?> createTable(String name) async {
    final model = await remoteDataSource.createTable(name);
    return model?.toEntity();
  }

  @override
  Future<TableEntity?> updateTable(String id, String name) async {
    final model = await remoteDataSource.updateTable(id, name);
    return model?.toEntity();
  }

  @override
  Future<bool> deleteTable(String id) async {
    return remoteDataSource.deleteTable(id);
  }
}
