import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/repositories/menu_repository.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/state/menu_digital_state.dart';
import 'package:flutter/foundation.dart';

class MenuDigitalController extends ChangeNotifier {
  MenuDigitalController(this._repository);

  final MenuRepository _repository;

  MenuDigitalState _state = const MenuDigitalState();

  MenuDigitalState get state => _state;

  Future<void> initialize() async {
    final storeName = await _repository.getStoreName();
    final categories = await _repository.getCategories();
    final items = await _repository.getMenuItems();

    _state = _state.copyWith(
      isLoading: false,
      storeName: storeName,
      categories: categories,
      items: items,
    );
    notifyListeners();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void updateCategory(String categoryId) {
    _state = _state.copyWith(selectedCategoryId: categoryId);
    notifyListeners();
  }

  void addToCart(MenuItemEntity item) {
    final updatedCart = Map<String, int>.from(_state.cartItems);
    updatedCart[item.id] = (updatedCart[item.id] ?? 0) + 1;

    _state = _state.copyWith(cartItems: updatedCart);
    notifyListeners();
  }

  void replaceCart(Map<String, int> quantityMap) {
    _state = _state.copyWith(cartItems: quantityMap);
    notifyListeners();
  }

  List<MenuItemEntity> get visibleItems {
    final loweredQuery = _state.searchQuery.toLowerCase().trim();

    return _state.items.where((item) {
      final isCategoryMatch =
          _state.selectedCategoryId == 'all' ||
          item.categoryId == _state.selectedCategoryId;
      final isTextMatch =
          loweredQuery.isEmpty ||
          item.name.toLowerCase().contains(loweredQuery) ||
          item.description.toLowerCase().contains(loweredQuery);

      return isCategoryMatch && isTextMatch;
    }).toList();
  }

  List<MenuCategory> get visibleCategories {
    return _state.categories.where((category) {
      if (category.id == 'all') {
        return true;
      }
      return visibleItems.any((item) => item.categoryId == category.id);
    }).toList();
  }

  Map<String, List<MenuItemEntity>> get groupedItems {
    final result = <String, List<MenuItemEntity>>{};
    for (final item in visibleItems) {
      result.putIfAbsent(item.categoryId, () => <MenuItemEntity>[]).add(item);
    }
    return result;
  }

  int get totalCartItemCount {
    return _state.cartItems.values.fold(0, (sum, qty) => sum + qty);
  }

  int get totalCartPrice {
    var total = 0;
    for (final entry in _state.cartItems.entries) {
      final item = _state.items.firstWhere((menu) => menu.id == entry.key);
      total += item.price * entry.value;
    }
    return total;
  }
}
