import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/waitlist_entry_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/state/table_management_state.dart';
import 'package:flutter/foundation.dart';

class TableManagementController extends ChangeNotifier {
  TableManagementController() : _state = TableManagementState.initial();

  TableManagementState _state;

  TableManagementState get state => _state;

  void setSelectedZone(String zone) {
    _state = _state.copyWith(selectedZone: zone);
    notifyListeners();
  }

  void setSelectedStatus(TableStatus? status) {
    _state = status == null
        ? _state.copyWith(clearSelectedStatus: true)
        : _state.copyWith(selectedStatus: status);
    notifyListeners();
  }

  void swapTableById(String draggedId, String targetId) {
    final tables = List.of(_state.tables);
    final draggedIndex = tables.indexWhere((table) => table.id == draggedId);
    final targetIndex = tables.indexWhere((table) => table.id == targetId);
    if (draggedIndex < 0 || targetIndex < 0 || draggedIndex == targetIndex) {
      return;
    }

    final dragged = tables.removeAt(draggedIndex);
    tables.insert(targetIndex, dragged);

    _state = _state.copyWith(
      tables: tables,
      selectedTableIndex: targetIndex,
    );
    notifyListeners();
  }

  void selectTable(String tableId) {
    final index = _state.tables.indexWhere((table) => table.id == tableId);
    if (index < 0) {
      return;
    }

    _state = _state.copyWith(selectedTableIndex: index);
    notifyListeners();
  }

  String closeCurrentTable() {
    final tables = List.of(_state.tables);
    final selectedIndex = _state.selectedTableIndex;
    final current = _state.currentTable;
    tables[selectedIndex] = current.copyWith(status: TableStatus.available);

    _state = _state.copyWith(tables: tables);
    notifyListeners();

    return 'Table ${_state.currentTable.id} closed. Checkout selesai.';
  }

  String autoAssignFromWaitlist(WaitlistEntryEntity entry) {
    final available = _state.tables.where((table) => table.status == TableStatus.available).toList();
    if (available.isEmpty) {
      return 'Belum ada meja available untuk auto assign.';
    }

    final match = available.firstWhere(
      (table) => table.capacity >= entry.pax,
      orElse: () => available.first,
    );

    final waitlist = List.of(_state.waitlist);
    final waitlistIndex = waitlist.indexOf(entry);
    if (waitlistIndex >= 0) {
      waitlist.removeAt(waitlistIndex);
    }

    final tables = List.of(_state.tables);
    final tableIndex = tables.indexWhere((table) => table.id == match.id);
    if (tableIndex >= 0) {
      tables[tableIndex] = tables[tableIndex].copyWith(status: TableStatus.reserved);
    }

    _state = _state.copyWith(
      waitlist: waitlist,
      tables: tables,
      selectedTableIndex: tableIndex >= 0 ? tableIndex : _state.selectedTableIndex,
    );
    notifyListeners();

    return '${entry.name} di-assign ke meja ${match.id}. ETA ${entry.etaMinutes} menit.';
  }
}
