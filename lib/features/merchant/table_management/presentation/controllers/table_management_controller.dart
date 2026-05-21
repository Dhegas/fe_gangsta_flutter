import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/waitlist_entry_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/repositories/table_management_repository.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/state/table_management_state.dart';
import 'package:flutter/foundation.dart';

class TableManagementController extends ChangeNotifier {
  TableManagementController(this._repository) : _state = TableManagementState.initial();

  final TableManagementRepository _repository;
  TableManagementState _state;

  TableManagementState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final tablesList = await _repository.getTables();
      _state = _state.copyWith(
        tables: tablesList,
        isLoading: false,
        selectedTableIndex: 0,
      );
    } catch (e) {
      print('Error initializing tables: $e');
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<bool> addTable(String name) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final newTable = await _repository.createTable(name);
      if (newTable != null) {
        final updatedList = List<TableEntity>.from(_state.tables)..add(newTable);
        _state = _state.copyWith(
          tables: updatedList,
          isLoading: false,
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating table: $e');
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
    return false;
  }

  Future<bool> updateTable(String id, String name) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final updatedTable = await _repository.updateTable(id, name);
      if (updatedTable != null) {
        final updatedList = _state.tables.map((t) => t.id == id ? updatedTable : t).toList();
        _state = _state.copyWith(
          tables: updatedList,
          isLoading: false,
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating table: $e');
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
    return false;
  }

  Future<bool> deleteTable(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final success = await _repository.deleteTable(id);
      if (success) {
        final updatedList = _state.tables.where((t) => t.id != id).toList();
        int newSelectedIndex = _state.selectedTableIndex;
        if (newSelectedIndex >= updatedList.length) {
          newSelectedIndex = updatedList.isEmpty ? 0 : updatedList.length - 1;
        }
        _state = _state.copyWith(
          tables: updatedList,
          selectedTableIndex: newSelectedIndex,
          isLoading: false,
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting table: $e');
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
    return false;
  }

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

    return 'Table ${_state.currentTable.name} closed. Checkout selesai.';
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

    return '${entry.name} di-assign ke meja ${match.name}. ETA ${entry.etaMinutes} menit.';
  }
}
