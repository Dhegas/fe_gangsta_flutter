import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/data/datasources/pos_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/data/repositories/pos_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/controllers/pos_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/widgets/pos_category_tabs.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/widgets/pos_menu_item_tile.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/presentation/widgets/pos_order_panel.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  late final PosController _controller;

  @override
  void initState() {
    super.initState();

    final repository = PosRepositoryImpl(PosLocalDataSource());
    _controller = PosController(repository)
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

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1120;

        return Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: MerchantSidebar(
                    merchantName: state.merchantName,
                    merchantRoleLabel: state.merchantRoleLabel,
                    selectedItem: MerchantNavItem.pos,
                    onTapItem: _handleSidebarTap,
                  ),
                ),
          body: SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      if (isDesktop)
                        MerchantSidebar(
                          merchantName: state.merchantName,
                          merchantRoleLabel: state.merchantRoleLabel,
                          selectedItem: MerchantNavItem.pos,
                          onTapItem: _handleSidebarTap,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isDesktop)
                                Builder(
                                  builder: (context) {
                                    return IconButton(
                                      onPressed: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                      icon: const Icon(Icons.menu_rounded),
                                    );
                                  },
                                ),
                              MerchantTopBar(
                                onSearchChanged: _controller.updateSearch,
                                isCompact: !isDesktop,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                'POS Workspace',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.space1),
                              Text(
                                'Pick menu items fast, assign table, and checkout smoothly.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              PosCategoryTabs(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onSelected: _controller.updateCategory,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Expanded(
                                child: isDesktop
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _PosMenuGrid(
                                              controller: _controller,
                                              isDesktopLayout: true,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.space4),
                                          Expanded(
                                            flex: 2,
                                            child: PosOrderPanel(
                                              tableLabels: state.tableLabels,
                                              selectedTable: state.selectedTableLabel,
                                              onSelectTable: _controller.selectTable,
                                              orderLines: state.orderLines,
                                              onIncreaseQty: _controller.increaseLineQty,
                                              onDecreaseQty: _controller.decreaseLineQty,
                                              subtotal: _controller.subtotal,
                                              taxAmount: _controller.taxAmount,
                                              grandTotal: _controller.grandTotal,
                                              onClear: _controller.clearOrder,
                                              onCheckout: _showCheckoutToast,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            child: _PosMenuGrid(
                                              controller: _controller,
                                              isDesktopLayout: false,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.space4),
                                          SizedBox(
                                            height: 360,
                                            child: PosOrderPanel(
                                              tableLabels: state.tableLabels,
                                              selectedTable: state.selectedTableLabel,
                                              onSelectTable: _controller.selectTable,
                                              orderLines: state.orderLines,
                                              onIncreaseQty: _controller.increaseLineQty,
                                              onDecreaseQty: _controller.decreaseLineQty,
                                              subtotal: _controller.subtotal,
                                              taxAmount: _controller.taxAmount,
                                              grandTotal: _controller.grandTotal,
                                              onClear: _controller.clearOrder,
                                              onCheckout: _showCheckoutToast,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showCheckoutToast() {
    if (_controller.state.orderLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan item dulu sebelum checkout.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout ${_controller.state.selectedTableLabel} • Total ${_formatRupiah(_controller.grandTotal)}',
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    final amount = value.round();
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  void _handleSidebarTap(MerchantNavItem item) {
    navigateToMerchantSection(context, item, MerchantNavItem.pos);
  }
}

class _PosMenuGrid extends StatelessWidget {
  const _PosMenuGrid({
    required this.controller,
    required this.isDesktopLayout,
  });

  final PosController controller;
  final bool isDesktopLayout;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = isDesktopLayout
            ? (width >= 920 ? 4 : 3)
            : width >= 1050
            ? 4
            : width >= 760
            ? 3
            : width >= 520
            ? 2
            : 1;

        if (items.isEmpty) {
          return Center(
            child: Text(
              'Item tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          );
        }

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: isDesktopLayout ? 0.86 : 0.95,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return PosMenuItemTile(
              item: item,
              currentQty: controller.qtyInCart(item.id),
              onAdd: () => controller.addItemToOrder(item),
            );
          },
        );
      },
    );
  }
}
