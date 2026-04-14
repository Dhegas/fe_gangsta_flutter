import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';

class MenuManagementState {
  const MenuManagementState({
    this.isLoading = true,
    this.merchantName = '',
    this.merchantRoleLabel = '',
    this.searchQuery = '',
    this.isSortMode = false,
    this.selectedCategoryId = 'all',
    this.categories = const [],
    this.items = const [],
  });

  final bool isLoading;
  final String merchantName;
  final String merchantRoleLabel;
  final String searchQuery;
  final bool isSortMode;
  final String selectedCategoryId;
  final List<MenuManagementCategory> categories;
  final List<MenuManagementItemEntity> items;

  MenuManagementState copyWith({
    bool? isLoading,
    String? merchantName,
    String? merchantRoleLabel,
    String? searchQuery,
    bool? isSortMode,
    String? selectedCategoryId,
    List<MenuManagementCategory>? categories,
    List<MenuManagementItemEntity>? items,
  }) {
    return MenuManagementState(
      isLoading: isLoading ?? this.isLoading,
      merchantName: merchantName ?? this.merchantName,
      merchantRoleLabel: merchantRoleLabel ?? this.merchantRoleLabel,
      searchQuery: searchQuery ?? this.searchQuery,
      isSortMode: isSortMode ?? this.isSortMode,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      items: items ?? this.items,
    );
  }
}
