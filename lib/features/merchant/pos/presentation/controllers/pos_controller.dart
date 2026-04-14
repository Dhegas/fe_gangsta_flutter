import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/repositories/pos_repository.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/state/pos_state.dart';
import 'package:flutter/foundation.dart';

class PosController extends ChangeNotifier {
  PosController(this._repository);

  final PosRepository _repository;

  PosState _state = const PosState();

  PosState get state => _state;

  Future<void> initialize() async {
    final merchantName = await _repository.getMerchantName();
    final merchantRoleLabel = await _repository.getMerchantRoleLabel();
    final categories = await _repository.getCategories();
    final menuItems = await _repository.getMenuItems();
    final tables = await _repository.getTables();

    _state = _state.copyWith(
      isLoading: false,
      merchantName: merchantName,
      merchantRoleLabel: merchantRoleLabel,
      categories: categories,
      menuItems: menuItems,
      tables: tables,
      selectedTableId: tables.isNotEmpty ? tables.first.id : 'takeaway',
    );
    notifyListeners();
  }

  void updateSearch(String value) {
    _state = _state.copyWith(searchQuery: value);
    notifyListeners();
  }

  void updateCategory(String categoryId) {
    _state = _state.copyWith(selectedCategoryId: categoryId);
    notifyListeners();
  }

  void selectTable(String tableId) {
    _state = _state.copyWith(selectedTableId: tableId);
    notifyListeners();
  }

  void addItemToOrder(PosMenuItemEntity item) {
    if (!item.isAvailable) {
      return;
    }

    final selectedTable = _state.selectedTable;
    final channel = selectedTable?.channel ?? PosSalesChannel.takeaway;
    final resolvedPrice = item.resolveUnitPrice(channel);

    final lines = [..._state.orderLines];
    final index = lines.indexWhere((line) => line.itemId == item.id);

    if (index == -1) {
      lines.add(
        PosOrderLineEntity(
          itemId: item.id,
          name: item.name,
          unitPrice: resolvedPrice,
          quantity: 1,
        ),
      );
    } else {
      final current = lines[index];
      lines[index] = current.copyWith(quantity: current.quantity + 1);
    }

    _state = _state.copyWith(orderLines: lines);
    notifyListeners();
  }

  void increaseLineQty(String itemId) {
    final lines = [..._state.orderLines];
    final index = lines.indexWhere((line) => line.itemId == itemId);
    if (index == -1) {
      return;
    }

    final current = lines[index];
    lines[index] = current.copyWith(quantity: current.quantity + 1);
    _state = _state.copyWith(orderLines: lines);
    notifyListeners();
  }

  void decreaseLineQty(String itemId) {
    final lines = [..._state.orderLines];
    final index = lines.indexWhere((line) => line.itemId == itemId);
    if (index == -1) {
      return;
    }

    final current = lines[index];
    if (current.quantity <= 1) {
      lines.removeAt(index);
    } else {
      lines[index] = current.copyWith(quantity: current.quantity - 1);
    }

    _state = _state.copyWith(orderLines: lines);
    notifyListeners();
  }

  void clearOrder() {
    _state = _state.copyWith(orderLines: []);
    notifyListeners();
  }

  List<PosMenuItemEntity> get filteredItems {
    final query = _state.searchQuery.toLowerCase().trim();

    return _state.menuItems.where((item) {
      if (!item.isAvailable) {
        return false;
      }

      final categoryMatch =
          _state.selectedCategoryId == 'all' ||
          item.categoryId == _state.selectedCategoryId;
      final queryMatch = query.isEmpty || item.name.toLowerCase().contains(query);

      return categoryMatch && queryMatch;
    }).toList();
  }

  int qtyInCart(String itemId) {
    for (final line in _state.orderLines) {
      if (line.itemId == itemId) {
        return line.quantity;
      }
    }
    return 0;
  }

  double get subtotal {
    return _state.orderLines.fold(
      0,
      (sum, line) => sum + (line.unitPrice * line.quantity),
    );
  }

  double get taxAmount => subtotal * _state.taxPercent;

  double get grandTotal => subtotal + taxAmount;

  bool get canCheckout {
    final table = _state.selectedTable;
    if (table == null) {
      return false;
    }
    if (table.isPhysicalTable && !table.isSelectable) {
      return false;
    }
    return _state.orderLines.isNotEmpty;
  }
}
