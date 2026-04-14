import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class BookingEntity {
  const BookingEntity({
    required this.customerName,
    required this.pax,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.assignedTableId,
  });

  final String customerName;
  final int pax;
  final String startTime;
  final int durationMinutes;
  final BookingStatus status;
  final String assignedTableId;
}
