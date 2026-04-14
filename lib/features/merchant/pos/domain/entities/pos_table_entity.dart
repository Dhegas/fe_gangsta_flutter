import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

enum PosSalesChannel { dineIn, takeaway, online }

class PosTableEntity {
  const PosTableEntity({
    required this.id,
    required this.label,
    required this.status,
    required this.channel,
  });

  final String id;
  final String label;
  final TableStatus status;
  final PosSalesChannel channel;

  bool get isPhysicalTable => channel == PosSalesChannel.dineIn;

  bool get isSelectable {
    if (!isPhysicalTable) {
      return true;
    }
    return status == TableStatus.available || status == TableStatus.reserved;
  }
}
