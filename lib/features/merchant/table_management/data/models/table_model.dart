import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class TableModel {
  const TableModel({
    required this.id,
    required this.capacity,
    required this.status,
    required this.zone,
  });

  final String id;
  final int capacity;
  final TableStatus status;
  final String zone;

  TableEntity toEntity() {
    return TableEntity(id: id, capacity: capacity, status: status, zone: zone);
  }
}
