import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/booking_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class BookingModel {
  const BookingModel({
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

  BookingEntity toEntity() {
    return BookingEntity(
      customerName: customerName,
      pax: pax,
      startTime: startTime,
      durationMinutes: durationMinutes,
      status: status,
      assignedTableId: assignedTableId,
    );
  }
}
