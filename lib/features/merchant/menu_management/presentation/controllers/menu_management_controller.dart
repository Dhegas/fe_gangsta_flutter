import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
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

  Future<void> toggleStock(String itemId, bool isInStock) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.toggleItemAvailable(itemId, isInStock);
    if (success) {
      final updatedItems = _state.items.map((item) {
        if (item.id != itemId) {
          return item;
        }
        return item.copyWith(
          isInStock: isInStock,
          remainingPortions: isInStock && item.remainingPortions == 0
              ? 99
              : item.remainingPortions,
        );
      }).toList();
      _state = _state.copyWith(items: updatedItems, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<void> toggleActive(String itemId, bool isActive) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.toggleItemAvailable(itemId, isActive);
    if (success) {
      final updatedItems = _state.items.map((item) {
        if (item.id != itemId) {
          return item;
        }
        return item.copyWith(
          isActive: isActive,
          isInStock: isActive,
        );
      }).toList();
      _state = _state.copyWith(items: updatedItems, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
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

  Future<bool> addItem(MenuManagementItemEntity newItem) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final created = await _repository.createItem(
      name: newItem.name,
      description: newItem.description,
      price: newItem.basePrice,
      categoryId: newItem.categoryId,
      imageUrl: newItem.imageUrl,
    );

    if (created != null) {
      final items = List<MenuManagementItemEntity>.from(_state.items)
        ..add(created.copyWith(
          sortOrder: _state.items.length,
          variants: newItem.variants,
          addOns: newItem.addOns,
          customNotes: newItem.customNotes,
          badges: newItem.badges,
        ));
      _state = _state.copyWith(items: items, isLoading: false);
      notifyListeners();
      return true;
    } else {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(MenuManagementItemEntity updatedItem) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final updated = await _repository.updateItem(
      id: updatedItem.id,
      name: updatedItem.name,
      description: updatedItem.description,
      price: updatedItem.basePrice,
      categoryId: updatedItem.categoryId,
      imageUrl: updatedItem.imageUrl,
    );

    if (updated != null) {
      final items = _state.items.map((item) {
        if (item.id == updatedItem.id) {
          return updated.copyWith(
            sortOrder: item.sortOrder,
            variants: updatedItem.variants,
            addOns: updatedItem.addOns,
            customNotes: updatedItem.customNotes,
            badges: updatedItem.badges,
            isActive: updatedItem.isActive,
            isInStock: updatedItem.isInStock,
            remainingPortions: updatedItem.remainingPortions,
          );
        }
        return item;
      }).toList();
      _state = _state.copyWith(items: items, isLoading: false);
      notifyListeners();
      return true;
    } else {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.deleteItem(itemId);
    if (success) {
      final remaining = _state.items.where((item) => item.id != itemId).toList();
      final normalized = <MenuManagementItemEntity>[];
      for (var i = 0; i < remaining.length; i++) {
        normalized.add(remaining[i].copyWith(sortOrder: i));
      }
      _state = _state.copyWith(items: normalized, isLoading: false);
      notifyListeners();
      return true;
    } else {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    }
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

  Future<void> createCategory(String name) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final newCat = await _repository.createCategory(name);
    if (newCat != null) {
      final updatedCategories = List<MenuManagementCategory>.from(_state.categories)..add(newCat);
      _state = _state.copyWith(categories: updatedCategories, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<void> updateCategoryLabel(String id, String name) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final updatedCat = await _repository.updateCategory(id, name);
    if (updatedCat != null) {
      final updatedCategories = _state.categories.map((c) {
        return c.id == id ? updatedCat : c;
      }).toList();
      _state = _state.copyWith(categories: updatedCategories, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<bool> deleteCategory(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.deleteCategory(id);
    if (success) {
      final updatedCategories = _state.categories.where((c) => c.id != id).toList();
      String selected = _state.selectedCategoryId;
      if (selected == id) {
        selected = 'all';
      }
      _state = _state.copyWith(
        categories: updatedCategories,
        selectedCategoryId: selected,
        isLoading: false,
      );
      notifyListeners();
      return true;
    } else {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleCategoryActiveStatus(String id, bool isActive) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.toggleCategoryActive(id, isActive);
    if (success) {
      final updatedCategories = _state.categories.map((c) {
        return c.id == id ? c.copyWith(isActive: isActive) : c;
      }).toList();
      _state = _state.copyWith(categories: updatedCategories, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<void> reorderAllCategories(List<String> orderedIds) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final success = await _repository.reorderCategories(orderedIds);
    if (success) {
      final Map<String, MenuManagementCategory> map = {
        for (final cat in _state.categories) cat.id: cat
      };
      final List<MenuManagementCategory> ordered = [];
      if (map.containsKey('all')) {
        ordered.add(map['all']!);
      }
      for (final id in orderedIds) {
        if (map.containsKey(id) && id != 'all') {
          ordered.add(map[id]!);
        }
      }
      for (final cat in _state.categories) {
        if (!ordered.contains(cat)) {
          ordered.add(cat);
        }
      }
      _state = _state.copyWith(categories: ordered, isLoading: false);
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }
}
