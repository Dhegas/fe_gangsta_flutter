import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';

class PosState {
  const PosState({
    this.isLoading = true,
    this.merchantName = '',
    this.merchantRoleLabel = '',
    this.categories = const [],
    this.menuItems = const [],
    this.tableLabels = const [],
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.selectedTableLabel = 'Takeaway',
    this.orderLines = const [],
    this.taxPercent = 0.10,
  });

  final bool isLoading;
  final String merchantName;
  final String merchantRoleLabel;
  final List<PosCategory> categories;
  final List<PosMenuItemEntity> menuItems;
  final List<String> tableLabels;
  final String selectedCategoryId;
  final String searchQuery;
  final String selectedTableLabel;
  final List<PosOrderLineEntity> orderLines;
  final double taxPercent;

  PosState copyWith({
    bool? isLoading,
    String? merchantName,
    String? merchantRoleLabel,
    List<PosCategory>? categories,
    List<PosMenuItemEntity>? menuItems,
    List<String>? tableLabels,
    String? selectedCategoryId,
    String? searchQuery,
    String? selectedTableLabel,
    List<PosOrderLineEntity>? orderLines,
    double? taxPercent,
  }) {
    return PosState(
      isLoading: isLoading ?? this.isLoading,
      merchantName: merchantName ?? this.merchantName,
      merchantRoleLabel: merchantRoleLabel ?? this.merchantRoleLabel,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      tableLabels: tableLabels ?? this.tableLabels,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTableLabel: selectedTableLabel ?? this.selectedTableLabel,
      orderLines: orderLines ?? this.orderLines,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }
}
