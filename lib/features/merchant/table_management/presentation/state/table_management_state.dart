import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/booking_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/waitlist_entry_entity.dart';

class TableManagementState {
  const TableManagementState({
    required this.tables,
    required this.bookings,
    required this.waitlist,
    required this.selectedZone,
    required this.selectedStatus,
    required this.selectedTableIndex,
  });

  factory TableManagementState.initial() {
    return TableManagementState(
      tables: const [
        TableEntity(id: 'T01', capacity: 2, status: TableStatus.available, zone: 'Indoor'),
        TableEntity(id: 'T02', capacity: 4, status: TableStatus.occupied, zone: 'Indoor'),
        TableEntity(id: 'T03', capacity: 6, status: TableStatus.reserved, zone: 'VIP'),
        TableEntity(id: 'T04', capacity: 4, status: TableStatus.cleaning, zone: 'Outdoor'),
        TableEntity(id: 'T05', capacity: 2, status: TableStatus.available, zone: 'Outdoor'),
        TableEntity(id: 'T06', capacity: 6, status: TableStatus.occupied, zone: 'VIP'),
        TableEntity(id: 'T07', capacity: 4, status: TableStatus.available, zone: 'Indoor'),
        TableEntity(id: 'T08', capacity: 2, status: TableStatus.reserved, zone: 'Indoor'),
      ],
      bookings: const [
        BookingEntity(
          customerName: 'Ari Wijaya',
          pax: 4,
          startTime: '18:30',
          durationMinutes: 90,
          status: BookingStatus.confirmed,
          assignedTableId: 'T08',
        ),
        BookingEntity(
          customerName: 'Nadya Putri',
          pax: 2,
          startTime: '19:00',
          durationMinutes: 60,
          status: BookingStatus.pending,
          assignedTableId: 'Auto',
        ),
        BookingEntity(
          customerName: 'Budi Santoso',
          pax: 6,
          startTime: '20:00',
          durationMinutes: 120,
          status: BookingStatus.noShow,
          assignedTableId: 'T03',
        ),
      ],
      waitlist: const [
        WaitlistEntryEntity(name: 'Walk-in #W12', pax: 3, etaMinutes: 12),
        WaitlistEntryEntity(name: 'Walk-in #W13', pax: 2, etaMinutes: 18),
        WaitlistEntryEntity(name: 'Walk-in #W14', pax: 5, etaMinutes: 25),
      ],
      selectedZone: 'All',
      selectedStatus: null,
      selectedTableIndex: 0,
    );
  }

  final List<TableEntity> tables;
  final List<BookingEntity> bookings;
  final List<WaitlistEntryEntity> waitlist;
  final String selectedZone;
  final TableStatus? selectedStatus;
  final int selectedTableIndex;

  List<TableEntity> get filteredTables {
    return tables.where((table) {
      final zoneMatch = selectedZone == 'All' || table.zone == selectedZone;
      final statusMatch = selectedStatus == null || table.status == selectedStatus;
      return zoneMatch && statusMatch;
    }).toList();
  }

  TableEntity get currentTable => tables[selectedTableIndex.clamp(0, tables.length - 1)];

  TableManagementState copyWith({
    List<TableEntity>? tables,
    List<BookingEntity>? bookings,
    List<WaitlistEntryEntity>? waitlist,
    String? selectedZone,
    TableStatus? selectedStatus,
    bool clearSelectedStatus = false,
    int? selectedTableIndex,
  }) {
    return TableManagementState(
      tables: tables ?? this.tables,
      bookings: bookings ?? this.bookings,
      waitlist: waitlist ?? this.waitlist,
      selectedZone: selectedZone ?? this.selectedZone,
      selectedStatus: clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedTableIndex: selectedTableIndex ?? this.selectedTableIndex,
    );
  }
}
