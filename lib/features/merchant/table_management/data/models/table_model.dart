import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class TableModel {
  const TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.zone,
  });

  final String id;
  final String name;
  final int capacity;
  final TableStatus status;
  final String zone;

  factory TableModel.fromJson(Map<String, dynamic> json, {TableStatus? status}) {
    final name = json['table_name']?.toString() ?? '';
    // Infer zone based on name
    String zone = 'Indoor';
    if (name.toUpperCase().contains('VIP')) {
      zone = 'VIP';
    } else if (name.toUpperCase().contains('OUTDOOR')) {
      zone = 'Outdoor';
    }

    return TableModel(
      id: json['id']?.toString() ?? '',
      name: name,
      capacity: 4, // default capacity
      status: status ?? TableStatus.available,
      zone: zone,
    );
  }

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      name: name,
      capacity: capacity,
      status: status,
      zone: zone,
    );
  }
}
