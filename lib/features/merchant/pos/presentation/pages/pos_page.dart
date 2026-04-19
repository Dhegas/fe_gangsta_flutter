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
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:flutter/material.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

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
        final itemCount = _controller.state.orderLines.fold(
          0,
          (sum, line) => sum + line.quantity,
        );
        final hasCart = itemCount > 0;

        return Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          floatingActionButton: !isDesktop && hasCart
              ? _FloatingCartBar(
                  itemCount: itemCount,
                  totalAmount: _controller.grandTotal,
                  onTap: _openMobileOrderSheet,
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: isDesktop
              ? null
              : MerchantBottomNav(
                  selectedItem: MerchantNavItem.pos,
                  onTapItem: _handleSidebarTap,
                ),
          body: SafeArea(
            bottom: false,
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
                              MerchantTopBar(
                                onSearchChanged: _controller.updateSearch,
                                isCompact: !isDesktop,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                'POS Workspace',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.space1),
                              Text(
                                'Pick menu items fast, assign table, and checkout smoothly.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _PosMenuGrid(
                                              controller: _controller,
                                              isDesktopLayout: true,
                                              bottomContentInset: 0,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AppSpacing.space4,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: PosOrderPanel(
                                              tables: state.tables,
                                              selectedTableId:
                                                  state.selectedTableId,
                                              onSelectTable:
                                                  _controller.selectTable,
                                              orderLines: state.orderLines,
                                              onIncreaseQty:
                                                  _controller.increaseLineQty,
                                              onDecreaseQty:
                                                  _controller.decreaseLineQty,
                                              subtotal: _controller.subtotal,
                                              taxAmount: _controller.taxAmount,
                                              grandTotal:
                                                  _controller.grandTotal,
                                              onClear: _controller.clearOrder,
                                              onCheckout: _showCheckoutToast,
                                            ),
                                          ),
                                        ],
                                      )
                                    : _PosMenuGrid(
                                        controller: _controller,
                                        isDesktopLayout: false,
                                        bottomContentInset: hasCart ? 148 : 84,
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
    if (!_controller.canCheckout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pastikan item ada di order dan meja/channel yang dipilih valid.',
          ),
        ),
      );
      return;
    }

    final table = _controller.state.selectedTable;
    final tableLabel = table?.label ?? 'Channel';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout $tableLabel • Total ${_formatRupiah(_controller.grandTotal)}',
        ),
      ),
    );
  }

  void _openMobileOrderSheet() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _MobileOrderSummaryPage(
          controller: _controller,
          onCheckout: _showCheckoutToast,
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
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }

    navigateToMerchantSection(context, item, MerchantNavItem.pos);
  }
}

class _FloatingCartBar extends StatelessWidget {
  const _FloatingCartBar({
    required this.itemCount,
    required this.totalAmount,
    required this.onTap,
  });

  final int itemCount;
  final double totalAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF7B4A), AppColors.primary],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29252427),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$itemCount item',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    _formatRupiah(totalAmount),
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  'View Order',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatRupiah(double value) {
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
}

class _MobileOrderSummaryPage extends StatefulWidget {
  const _MobileOrderSummaryPage({
    required this.controller,
    required this.onCheckout,
  });

  final PosController controller;
  final VoidCallback onCheckout;

  @override
  State<_MobileOrderSummaryPage> createState() =>
      _MobileOrderSummaryPageState();
}

class _MobileOrderSummaryPageState extends State<_MobileOrderSummaryPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdated);
    super.dispose();
  }

  void _onControllerUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        title: const Text('Summary Order'),
        centerTitle: false,
        backgroundColor: AppColors.surfaceNeutral,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            children: [
              Expanded(
                child: PosOrderPanel(
                  tables: state.tables,
                  selectedTableId: state.selectedTableId,
                  onSelectTable: widget.controller.selectTable,
                  orderLines: state.orderLines,
                  onIncreaseQty: widget.controller.increaseLineQty,
                  onDecreaseQty: widget.controller.decreaseLineQty,
                  subtotal: widget.controller.subtotal,
                  taxAmount: widget.controller.taxAmount,
                  grandTotal: widget.controller.grandTotal,
                  onClear: widget.controller.clearOrder,
                  onCheckout: _handleCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCheckout() {
    widget.onCheckout();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _PosMenuGrid extends StatelessWidget {
  const _PosMenuGrid({
    required this.controller,
    required this.isDesktopLayout,
    required this.bottomContentInset,
  });

  final PosController controller;
  final bool isDesktopLayout;
  final double bottomContentInset;

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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.only(bottom: bottomContentInset),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: isDesktopLayout
                ? (width >= 920 ? 0.78 : 0.72)
                : (width >= 760 ? 0.92 : 0.86),
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
