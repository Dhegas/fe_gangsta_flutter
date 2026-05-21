import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/dining_table_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/repositories/menu_repository.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/repositories/order_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/controllers/customer_cart_controller.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/pages/customer_checkout_preview_page.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/cart_item_tile.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/guest_info_bottom_sheet.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/order_totals_card.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/payment_method_selector.dart';
import 'package:flutter/material.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({
    required this.initialItems,
    required this.tenantSlug,
    this.tableId,
    super.key,
  });

  final List<CartItemEntity> initialItems;
  final String tenantSlug;
  final String? tableId;

  @override
  State<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage> {
  late final CustomerCartController _controller;
  late final MenuRepository _menuRepository;

  String? _selectedTableId;
  String? _selectedTableName;

  @override
  void initState() {
    super.initState();
    _menuRepository = MenuRepositoryImpl(
      MenuLocalDataSource(),
      MenuRemoteDataSource(ApiClient()),
    );
    
    _selectedTableId = widget.tableId;
    _selectedTableName = widget.tableId != null ? 'Meja Terpilih' : null;

    final repository = OrderRepositoryImpl(
      OrderLocalDataSource(),
      OrderRemoteDataSource(ApiClient()),
    );
    _controller = CustomerCartController(
      repository: repository,
      initialItems: widget.initialItems,
    )
      ..addListener(_refresh)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _showTableSelectionSheet() async {
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Pilih Meja Anda',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Pilih nomor meja tempat Anda duduk untuk melanjutkan pesanan',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Expanded(
                    child: FutureBuilder<List<DiningTableEntity>>(
                      future: _menuRepository.getTablesBySlug(widget.tenantSlug),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Gagal mengambil daftar meja: ${snapshot.error}',
                              style: const TextStyle(color: AppColors.statusError),
                            ),
                          );
                        }

                        final tables = snapshot.data ?? [];
                        if (tables.isEmpty) {
                          return const Center(
                            child: Text('Tidak ada meja aktif untuk merchant ini.'),
                          );
                        }

                        return GridView.builder(
                          controller: scrollController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.space3,
                            mainAxisSpacing: AppSpacing.space3,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: tables.length,
                          itemBuilder: (context, index) {
                            final table = tables[index];
                            final isOccupied = table.status == 'occupied';
                            final isSelected = _selectedTableId == table.id;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedTableId = table.id;
                                  _selectedTableName = table.tableName;
                                });
                                Navigator.of(bottomSheetContext).pop();
                              },
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceStrong.withValues(alpha: 0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(AppSpacing.space3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.table_restaurant_rounded,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      size: 28,
                                    ),
                                    const SizedBox(height: AppSpacing.space2),
                                    Text(
                                      table.tableName,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.space2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOccupied
                                            ? AppColors.statusWarning.withValues(alpha: 0.1)
                                            : AppColors.statusSuccess.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isOccupied ? 'Terisi' : 'Tersedia',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isOccupied
                                              ? AppColors.statusWarning
                                              : AppColors.statusSuccess,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _goToCheckoutPreview() async {
    // Validation Check: Dining Table must be selected
    if (_selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Colors.white),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  'Silakan pilih meja Anda terlebih dahulu!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          margin: const EdgeInsets.all(AppSpacing.space4),
        ),
      );
      return;
    }

    GuestCustomerEntity? guest;

    // Check if user is a Guest (no active token)
    final token = ApiClient.activeToken ?? '';
    if (token.isEmpty) {
      guest = await showModalBottomSheet<GuestCustomerEntity>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        builder: (_) => const GuestInfoBottomSheet(),
      );

      if (guest == null) {
        return; // User canceled the guest form
      }
    }

    if (!mounted) return;

    final isSubmitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomerCheckoutPreviewPage(
          items: _controller.state.items,
          orderNote: _controller.state.orderNote,
          paymentMethod: _controller.selectedPaymentMethod,
          subtotal: _controller.subtotal,
          additionalFee: _controller.additionalFee,
          totalPayment: _controller.totalPayment,
          tenantSlug: widget.tenantSlug,
          tableId: _selectedTableId,
          tableName: _selectedTableName,
          guest: guest,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (isSubmitted == true) {
      Navigator.of(context).pop(<String, int>{});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Keranjang masih kosong',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        'Tambahkan menu dulu dari halaman menu digital.',
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _showTableSelectionSheet,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.space4),
                        decoration: BoxDecoration(
                          color: _selectedTableId != null
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _selectedTableId != null
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.surfaceStrong.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.table_restaurant_rounded,
                              color: _selectedTableId != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 28,
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedTableId != null
                                        ? 'Meja Terpilih'
                                        : 'Meja Belum Dipilih',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedTableName ??
                                        (_selectedTableId != null
                                            ? 'Meja ID: ${_selectedTableId!.substring(0, 8)}'
                                            : 'Pilih Nomor Meja Anda'),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedTableId != null
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: _selectedTableId != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text('Item dipilih', style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.space3),
                    ...state.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space3,
                        ),
                        child: CartItemTile(
                          item: item,
                          onIncrease: () => _controller.increaseQty(item.id),
                          onDecrease: () => _controller.decreaseQty(item.id),
                          onRemove: () => _controller.removeItem(item.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text('Catatan pesanan', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.space2),
                    TextField(
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: tanpa bawang, sambal dipisah.',
                      ),
                      onChanged: _controller.updateOrderNote,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text('Metode pembayaran', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.space2),
                    PaymentMethodSelector(
                      methods: state.paymentMethods,
                      selectedId: state.selectedPaymentMethodId,
                      onChanged: _controller.updatePaymentMethod,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    OrderTotalsCard(
                      subtotal: _controller.subtotal,
                      additionalFee: _controller.additionalFee,
                      total: _controller.totalPayment,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToCheckoutPreview,
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
