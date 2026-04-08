import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';

class MenuDigitalState {
  const MenuDigitalState({
    this.isLoading = true,
    this.storeName = '',
    this.categories = const [],
    this.items = const [],
    this.searchQuery = '',
    this.selectedCategoryId = 'all',
    this.cartItems = const {},
  });

  final bool isLoading;
  final String storeName;
  final List<MenuCategory> categories;
  final List<MenuItemEntity> items;
  final String searchQuery;
  final String selectedCategoryId;
  final Map<String, int> cartItems;

  MenuDigitalState copyWith({
    bool? isLoading,
    String? storeName,
    List<MenuCategory>? categories,
    List<MenuItemEntity>? items,
    String? searchQuery,
    String? selectedCategoryId,
    Map<String, int>? cartItems,
  }) {
    return MenuDigitalState(
      isLoading: isLoading ?? this.isLoading,
      storeName: storeName ?? this.storeName,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}
