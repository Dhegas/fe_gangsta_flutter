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

  void toggleStock(String itemId, bool isInStock) {
    final updatedItems = _state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      return item.copyWith(isInStock: isInStock);
    }).toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  List<MenuManagementItemEntity> get filteredItems {
    final query = _state.searchQuery.toLowerCase().trim();

    return _state.items.where((item) {
      final categoryMatch =
          _state.selectedCategoryId == 'all' ||
          item.categoryId == _state.selectedCategoryId;
      final textMatch = query.isEmpty || item.name.toLowerCase().contains(query);
      return categoryMatch && textMatch;
    }).toList();
  }
}
