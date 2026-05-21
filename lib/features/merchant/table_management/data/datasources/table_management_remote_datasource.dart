import 'package:fe_gangsta_flutter/features/merchant/table_management/data/models/table_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

abstract class TableManagementRemoteDataSource {
  Future<List<TableModel>> fetchTables();
  Future<TableStatus> fetchTableStatus(String id);
  Future<TableModel?> createTable(String name);
  Future<TableModel?> updateTable(String id, String name);
  Future<bool> deleteTable(String id);
}
