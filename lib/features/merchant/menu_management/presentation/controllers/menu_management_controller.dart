import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/repositories/menu_management_repository.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/state/menu_management_state.dart';
import 'package:flutter/foundation.dart';

class MenuManagementController extends ChangeNotifier {
  MenuManagementController(this._repository);

  final MenuManagementRepository _repository;

  MenuManagementState _state = const MenuManagementState();

  MenuManagementState get state => _state;

  Future<void> initialize() async {
    final merchantName = await _repository.getMerchantName();
    final merchantRoleLabel = await _repository.getMerchantRoleLabel();
    final categories = await _repository.getCategories();
    final items = await _repository.getItems();

    _state = _state.copyWith(
      isLoading: false,
      merchantName: merchantName,
      merchantRoleLabel: merchantRoleLabel,
      categories: categories,
      items: items,
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

  void setSortMode(bool isSortMode) {
    _state = _state.copyWith(isSortMode: isSortMode);
    notifyListeners();
  }

  void toggleStock(String itemId, bool isInStock) {
    final updatedItems = _state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      return item.copyWith(
        isInStock: isInStock,
        remainingPortions: isInStock && item.remainingPortions == 0
            ? 1
            : item.remainingPortions,
      );
    }).toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  void toggleActive(String itemId, bool isActive) {
    final updatedItems = _state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      return item.copyWith(isActive: isActive);
    }).toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  void updateRemainingPortions(String itemId, int remainingPortions) {
    final safePortions = remainingPortions < 0 ? 0 : remainingPortions;
    final updatedItems = _state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      return item.copyWith(
        remainingPortions: safePortions,
        isInStock: safePortions > 0,
      );
    }).toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  void simulateIncomingOrder(String itemId) {
    final updatedItems = _state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      final nextPortions = item.remainingPortions > 0
          ? item.remainingPortions - 1
          : 0;
      return item.copyWith(
        remainingPortions: nextPortions,
        isInStock: nextPortions > 0,
      );
    }).toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  void addItem(MenuManagementItemEntity newItem) {
    final items = List<MenuManagementItemEntity>.from(_state.items)
      ..add(newItem.copyWith(sortOrder: _state.items.length));
    _state = _state.copyWith(items: items);
    notifyListeners();
  }

  void updateItem(MenuManagementItemEntity updatedItem) {
    final items = _state.items.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    _state = _state.copyWith(items: items);
    notifyListeners();
  }

  void deleteItem(String itemId) {
    final remaining = _state.items.where((item) => item.id != itemId).toList();
    final normalized = <MenuManagementItemEntity>[];
    for (var i = 0; i < remaining.length; i++) {
      normalized.add(remaining[i].copyWith(sortOrder: i));
    }
    _state = _state.copyWith(items: normalized);
    notifyListeners();
  }

  void reorderItems(int oldIndex, int newIndex) {
    final ordered = List<MenuManagementItemEntity>.from(_state.items)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    var targetIndex = newIndex;
    if (oldIndex < targetIndex) {
      targetIndex -= 1;
    }

    final item = ordered.removeAt(oldIndex);
    ordered.insert(targetIndex, item);

    final normalized = <MenuManagementItemEntity>[];
    for (var i = 0; i < ordered.length; i++) {
      normalized.add(ordered[i].copyWith(sortOrder: i));
    }

    _state = _state.copyWith(items: normalized);
    notifyListeners();
  }

  void applySortByIds(List<String> orderedIds) {
    final map = <String, MenuManagementItemEntity>{
      for (final item in _state.items) item.id: item,
    };

    final normalized = <MenuManagementItemEntity>[];
    for (var i = 0; i < orderedIds.length; i++) {
      final item = map[orderedIds[i]];
      if (item != null) {
        normalized.add(item.copyWith(sortOrder: i));
      }
    }

    for (final item in _state.items) {
      if (!orderedIds.contains(item.id)) {
        normalized.add(item.copyWith(sortOrder: normalized.length));
      }
    }

    _state = _state.copyWith(items: normalized);
    notifyListeners();
  }

  List<MenuManagementItemEntity> get filteredItems {
    final query = _state.searchQuery.toLowerCase().trim();

    final filtered = _state.items.where((item) {
      final categoryMatch =
          _state.selectedCategoryId == 'all' ||
          item.categoryId == _state.selectedCategoryId;
      final textMatch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return categoryMatch && textMatch;
    }).toList();

    filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return filtered;
  }
}
