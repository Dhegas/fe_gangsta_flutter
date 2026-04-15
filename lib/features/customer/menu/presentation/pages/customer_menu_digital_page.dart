import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/controllers/menu_digital_controller.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/state/menu_digital_state.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/cart_summary_bar.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_item_card.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_search_field.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/pages/customer_cart_page.dart';
import 'package:flutter/material.dart';

class CustomerMenuDigitalPage extends StatefulWidget {
  const CustomerMenuDigitalPage({required this.storeId, super.key});

  final String storeId;

  @override
  State<CustomerMenuDigitalPage> createState() =>
      _CustomerMenuDigitalPageState();
}

class _CustomerMenuDigitalPageState extends State<CustomerMenuDigitalPage> {
  late final MenuDigitalController _controller;
  int _mobileNavIndex = 0;

  @override
  void initState() {
    super.initState();

    final repository = MenuRepositoryImpl(MenuLocalDataSource());
    _controller = MenuDigitalController(repository)
      ..addListener(_onControllerUpdated)
      ..initialize(widget.storeId);
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

  bool _isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  Future<void> _openCategoryFilterSheet() async {
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) {
        final state = _controller.state;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Text('Filter Kategori', style: textTheme.titleLarge),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = state.selectedCategoryId == category.id;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withValues(
                      alpha: 0.10,
                    ),
                    title: Text(category.name),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      _controller.updateCategory(category.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCartPage() async {
    final state = _controller.state;

    final initialItems = state.cartItems.entries
        .map((entry) {
          final menuItem = state.items.firstWhere(
            (item) => item.id == entry.key,
          );
          return CartItemEntity(
            id: menuItem.id,
            name: menuItem.name,
            description: menuItem.description,
            price: menuItem.price,
            imageUrl: menuItem.imageUrl,
            quantity: entry.value,
          );
        })
        .where((item) => item.quantity > 0)
        .toList();

    final result = await Navigator.of(context).push<Map<String, int>>(
      MaterialPageRoute(
        builder: (_) => CustomerCartPage(initialItems: initialItems),
      ),
    );

    if (result == null) {
      return;
    }

    _controller.replaceCart(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = _isMobileLayout(context);
    final showMessageView = !isMobile || _mobileNavIndex == 0;

    return Scaffold(
      appBar: AppBar(title: Text(state.storeName)),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _mobileNavIndex,
              onDestinationSelected: (index) {
                setState(() => _mobileNavIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Pesan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : showMessageView
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space4,
                      AppSpacing.space4,
                      0,
                    ),
                    child: MenuSearchField(onChanged: _controller.updateSearch),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space2,
                      AppSpacing.space4,
                      AppSpacing.space3,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Kategori: ${_selectedCategoryName(state)}',
                          style: textTheme.labelLarge,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openCategoryFilterSheet,
                          icon: const Icon(Icons.tune),
                          label: const Text('Filter'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _controller.visibleItems.isEmpty
                        ? Center(
                            child: Text(
                              'Menu tidak ditemukan',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.space4,
                              0,
                              AppSpacing.space4,
                              AppSpacing.space12,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppSpacing.space3,
                                  mainAxisSpacing: AppSpacing.space3,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: _controller.visibleItems.length,
                            itemBuilder: (context, index) {
                              final item = _controller.visibleItems[index];
                              return MenuItemCard(
                                item: item,
                                onAddTap: () => _controller.addToCart(item),
                              );
                            },
                          ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _controller.totalCartItemCount > 0
                        ? CartSummaryBar(
                            totalItems: _controller.totalCartItemCount,
                            totalPrice: _controller.totalCartPrice,
                            onTap: _openCartPage,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  Text('Riwayat Pesanan', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Riwayat masih menggunakan data dummy sementara.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  ..._dummyHistoryItems.map(
                    (history) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(history.title),
                        subtitle: Text('${history.date} · ${history.status}'),
                        trailing: Text(history.total),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _selectedCategoryName(MenuDigitalState state) {
    for (final category in state.categories) {
      if (category.id == state.selectedCategoryId) {
        return category.name;
      }
    }
    return 'Semua';
  }

  List<_HistoryItem> get _dummyHistoryItems {
    return const [
      _HistoryItem(
        title: 'Bakso Urat + Es Teh',
        date: '15 Apr 2026',
        status: 'Selesai',
        total: 'Rp42.000',
      ),
      _HistoryItem(
        title: 'Mie Ayam Komplit',
        date: '13 Apr 2026',
        status: 'Selesai',
        total: 'Rp28.000',
      ),
      _HistoryItem(
        title: 'Soto Ayam + Kerupuk',
        date: '11 Apr 2026',
        status: 'Selesai',
        total: 'Rp31.000',
      ),
    ];
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.date,
    required this.status,
    required this.total,
  });

  final String title;
  final String date;
  final String status;
  final String total;
}
