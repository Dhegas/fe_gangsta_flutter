import 'dart:ui';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/controllers/menu_digital_controller.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/state/menu_digital_state.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/cart_summary_bar.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_item_card.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/widgets/menu_search_field.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/repositories/order_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/pages/customer_cart_page.dart';
import 'package:flutter/material.dart';

class CustomerMenuDigitalPage extends StatefulWidget {
  const CustomerMenuDigitalPage({
    required this.storeId,
    this.tableId,
    super.key,
  });

  final String storeId;
  final String? tableId;

  @override
  State<CustomerMenuDigitalPage> createState() =>
      _CustomerMenuDigitalPageState();
}

class _CustomerMenuDigitalPageState extends State<CustomerMenuDigitalPage> {
  late final MenuDigitalController _controller;
  late final OrderRepository _orderRepository;
  int _mobileNavIndex = 0;

  List<OrderEntity> _historyItems = [];
  bool _isHistoryLoading = false;
  String? _historyErrorMessage;

  @override
  void initState() {
    super.initState();

    _orderRepository = OrderRepositoryImpl(
      OrderLocalDataSource(),
      OrderRemoteDataSource(ApiClient()),
    );

    final repository = MenuRepositoryImpl(
      MenuLocalDataSource(),
      MenuRemoteDataSource(ApiClient()),
    );
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

  Future<void> _fetchHistory() async {
    setState(() {
      _isHistoryLoading = true;
      _historyErrorMessage = null;
    });

    try {
      final history = await _orderRepository.getOrderHistory(
        tenantId: widget.storeId,
      );
      if (mounted) {
        setState(() {
          _historyItems = history;
          _isHistoryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyErrorMessage = e.toString().replaceAll('ApiException: ', '');
          _isHistoryLoading = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return AppColors.primary;
      case 'COMPLETED':
        return AppColors.statusSuccess;
      case 'CANCELLED':
        return AppColors.statusError;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _showOrderDetails(OrderEntity orderBrief) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = await _orderRepository.getOrderDetails(
        tenantId: widget.storeId,
        orderId: orderBrief.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading spinner

      await _showReceiptDialog(order);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading spinner

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil detail pesanan: $e'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  Future<void> _showReceiptDialog(OrderEntity order) async {
    final textTheme = Theme.of(context).textTheme;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          'Struk Transaksi',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${order.id.substring(0, 8).toUpperCase()}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Status',
                            order.status.toUpperCase(),
                            valueColor: _statusColor(order.status),
                            isBold: true,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          _buildDetailRow(
                            'Tanggal',
                            _formatDateTime(order.createdAt),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          _buildDetailRow(
                            'Meja',
                            order.diningTablesId.length > 8
                                ? order.diningTablesId.substring(0, 8)
                                : order.diningTablesId,
                            isBold: true,
                          ),
                          const SizedBox(height: AppSpacing.space4),

                          const DashedDivider(color: AppColors.surfaceStrong),
                          const SizedBox(height: AppSpacing.space4),

                          Text(
                            'Item Pesanan',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.space2,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.quantity}x ${item.menuName}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (item.notes.isNotEmpty)
                                          Text(
                                            'Catatan: ${item.notes}',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textMuted,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.toRupiah(
                                      item.subtotal.toInt(),
                                    ),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: AppSpacing.space4),
                          const DashedDivider(color: AppColors.surfaceStrong),
                          const SizedBox(height: AppSpacing.space4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.toRupiah(
                                  order.totalPrice.toInt(),
                                ),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space5),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.space3,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return isoString;
    }
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
        builder: (_) => CustomerCartPage(
          initialItems: initialItems,
          tenantSlug: _controller.store?.slug ?? '',
          tableId: widget.tableId,
        ),
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
                if (index == 1) {
                  _fetchHistory();
                }
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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final isWebsite = width >= 800;
                              final isTablet = width >= 550 && width < 800;

                              final columns = isWebsite ? 4 : 2;
                              final availableWidth =
                                  width - (AppSpacing.space4 * 2);
                              final tileWidth =
                                  (availableWidth -
                                      ((columns - 1) * AppSpacing.space3)) /
                                  columns;

                              final double targetTileHeight;
                              if (isWebsite) {
                                targetTileHeight = 280.0;
                              } else if (isTablet) {
                                targetTileHeight = 270.0;
                              } else {
                                targetTileHeight = 255.0;
                              }

                              final calculatedAspectRatio =
                                  (tileWidth / targetTileHeight).clamp(
                                    0.5,
                                    2.0,
                                  );

                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.space4,
                                  0,
                                  AppSpacing.space4,
                                  AppSpacing.space12,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: AppSpacing.space3,
                                      mainAxisSpacing: AppSpacing.space3,
                                      childAspectRatio: calculatedAspectRatio,
                                    ),
                                itemCount: _controller.visibleItems.length,
                                itemBuilder: (context, index) {
                                  final item = _controller.visibleItems[index];
                                  return MenuItemCard(
                                    item: item,
                                    onAddTap: () => _controller.addToCart(item),
                                  );
                                },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Riwayat Pesanan', style: textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _fetchHistory,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  if (_isHistoryLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space8,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_historyErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space8,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.statusError,
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Text(
                              _historyErrorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.statusError,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            ElevatedButton(
                              onPressed: _fetchHistory,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_historyItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space8,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 64,
                              color: AppColors.surfaceStrong.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              'Belum ada transaksi di outlet ini',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space1),
                            Text(
                              'Silakan pesan menu lezat kami terlebih dahulu.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._historyItems.map(
                      (order) => Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.space3,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: BorderSide(
                            color: AppColors.surfaceStrong.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => _showOrderDetails(order),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.space2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      order.status,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: _statusColor(order.status),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pesanan #${order.id.substring(0, 8).toUpperCase()}',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(order.createdAt),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.toRupiah(
                                        order.totalPrice.toInt(),
                                      ),
                                      style: textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.space2,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          order.status,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.sm,
                                        ),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(order.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.color = Colors.grey});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
