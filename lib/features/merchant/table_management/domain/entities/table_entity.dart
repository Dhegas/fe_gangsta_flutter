import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class TableEntity {
  const TableEntity({
    required this.id,
    required this.capacity,
    required this.status,
    required this.zone,
  });

  final String id;
  final int capacity;
  final TableStatus status;
  final String zone;

  TableEntity copyWith({
    String? id,
    int? capacity,
    TableStatus? status,
    String? zone,
  }) {
    return TableEntity(
      id: id ?? this.id,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      zone: zone ?? this.zone,
    );
  }
}
