import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';

class PosState {
  const PosState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.merchantName = '',
    this.merchantRoleLabel = '',
    this.categories = const [],
    this.menuItems = const [],
    this.tables = const [],
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.selectedTableId = 'takeaway',
    this.salesChannel = PosSalesChannel.dineIn,
    this.orderLines = const [],
    this.taxPercent = 0.0,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String merchantName;
  final String merchantRoleLabel;
  final List<PosCategory> categories;
  final List<PosMenuItemEntity> menuItems;
  final List<PosTableEntity> tables;
  final String selectedCategoryId;
  final String searchQuery;
  final String selectedTableId;
  final PosSalesChannel salesChannel;
  final List<PosOrderLineEntity> orderLines;
  final double taxPercent;

  PosTableEntity? get selectedTable {
    for (final table in tables) {
      if (table.id == selectedTableId) {
        return table;
      }
    }
    return tables.isNotEmpty ? tables.first : null;
  }

  PosState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? merchantName,
    String? merchantRoleLabel,
    List<PosCategory>? categories,
    List<PosMenuItemEntity>? menuItems,
    List<PosTableEntity>? tables,
    String? selectedCategoryId,
    String? searchQuery,
    String? selectedTableId,
    PosSalesChannel? salesChannel,
    List<PosOrderLineEntity>? orderLines,
    double? taxPercent,
  }) {
    return PosState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      merchantName: merchantName ?? this.merchantName,
      merchantRoleLabel: merchantRoleLabel ?? this.merchantRoleLabel,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      tables: tables ?? this.tables,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      salesChannel: salesChannel ?? this.salesChannel,
      orderLines: orderLines ?? this.orderLines,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }
}
