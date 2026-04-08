import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/controllers/menu_digital_controller.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/cart_summary_bar.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/category_filter_chips.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_item_card.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_search_field.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/store_header.dart';
import 'package:flutter/material.dart';

class CustomerMenuDigitalPage extends StatefulWidget {
  const CustomerMenuDigitalPage({super.key});

  @override
  State<CustomerMenuDigitalPage> createState() =>
      _CustomerMenuDigitalPageState();
}

class _CustomerMenuDigitalPageState extends State<CustomerMenuDigitalPage> {
  late final MenuDigitalController _controller;

  @override
  void initState() {
    super.initState();

    final repository = MenuRepositoryImpl(MenuLocalDataSource());
    _controller = MenuDigitalController(repository)
      ..addListener(_onControllerUpdated)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerUpdated)
      ..dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    setState(() {});
  }

  void _showCartPreview() {
    final totalItems = _controller.totalCartItemCount;
    final totalPrice = _controller.totalCartPrice;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Keranjang: $totalItems item • Total Rp ${_formatRupiah(totalPrice)}',
        ),
      ),
    );
  }

  String _formatRupiah(int value) {
    final reversed = value.toString().split('').reversed.toList();
    final chunks = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }

    return chunks.reversed.join('.');
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Digital')),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StoreHeader(storeName: state.storeName),
                          const SizedBox(height: AppSpacing.space4),
                          MenuSearchField(onChanged: _controller.updateSearch),
                          const SizedBox(height: AppSpacing.space3),
                          CategoryFilterChips(
                            categories: _controller.visibleCategories,
                            selectedId: state.selectedCategoryId,
                            onSelected: _controller.updateCategory,
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          if (_controller.visibleItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.space8,
                              ),
                              child: Center(
                                child: Text(
                                  'Menu tidak ditemukan',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._buildGroupedMenu(context),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _controller.totalCartItemCount > 0
                        ? CartSummaryBar(
                            totalItems: _controller.totalCartItemCount,
                            totalPrice: _controller.totalCartPrice,
                            onTap: _showCartPreview,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildGroupedMenu(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;
    final groupedItems = _controller.groupedItems;

    final categoriesToRender = state.selectedCategoryId == 'all'
        ? state.categories.where((c) => c.id != 'all').toList()
        : state.categories
              .where((c) => c.id == state.selectedCategoryId)
              .toList();

    final widgets = <Widget>[];

    for (final category in categoriesToRender) {
      final items = groupedItems[category.id] ?? <MenuItemEntity>[];
      if (items.isEmpty) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space2),
          child: Text(category.name, style: textTheme.titleLarge),
        ),
      );

      for (var i = 0; i < items.length; i++) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: MenuItemCard(
              item: items[i],
              onAddTap: () => _controller.addToCart(items[i]),
            ),
          ),
        );
      }

      widgets.add(const SizedBox(height: AppSpacing.space2));
    }

    return widgets;
  }
}
