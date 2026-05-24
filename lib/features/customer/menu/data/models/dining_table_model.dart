import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/dining_table_entity.dart';

class DiningTableModel extends DiningTableEntity {
  const DiningTableModel({
    required super.id,
    required super.tenantId,
    required super.tableName,
    required super.status,
  });

  factory DiningTableModel.fromJson(Map<String, dynamic> json) {
    return DiningTableModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      tableName: json['tableName'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'tableName': tableName,
      'status': status,
    };
  }
}
