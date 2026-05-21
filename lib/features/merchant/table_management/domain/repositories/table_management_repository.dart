import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';

abstract class TableManagementRepository {
  Future<void> syncTables();
  Future<List<TableEntity>> getTables();
  Future<TableEntity?> createTable(String name);
  Future<TableEntity?> updateTable(String id, String name);
  Future<bool> deleteTable(String id);
}
