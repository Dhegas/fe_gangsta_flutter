import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
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
                              Text(
                                'POS Workspace',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              if (PosLocalDataSource.wasFallbackTriggered)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                                  padding: const EdgeInsets.all(AppSpacing.space3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    border: Border.all(color: Colors.amber.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                                      const SizedBox(width: AppSpacing.space3),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '⚠️ API KONEKSI GAGAL - MENGGUNAKAN FALLBACK MOCK DATA',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber.shade900,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Gagal memuat data dari server backend. Error: ${PosLocalDataSource.lastErrorMessage}',
                                              style: TextStyle(
                                                color: Colors.amber.shade800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              MerchantTopBar(
                                onSearchChanged: _controller.updateSearch,
                                searchQuery: state.searchQuery,
                                isCompact: !isDesktop,
                              ),
                              const SizedBox(height: AppSpacing.space1),
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
                                              salesChannel: state.salesChannel,
                                              onSelectChannel:
                                                  _controller.updateSalesChannel,
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
                                              onCheckout: _openCheckoutDialog,
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

  String _formatRupiah(double value) {
    return _FloatingCartBar._formatRupiah(value);
  }

  void _showReceiptDialog({
    required String customerName,
    required String? tableName,
    required List<PosOrderLineEntity> items,
    required double totalAmount,
  }) {
    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 54,
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'Pesanan Berhasil!',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.space4),
                const Divider(),
                const SizedBox(height: AppSpacing.space3),
                _buildReceiptRow('Pelanggan', customerName),
                _buildReceiptRow('Meja', tableName ?? 'Bawa Pulang (Takeaway)'),
                const SizedBox(height: AppSpacing.space3),
                const Divider(),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'Rincian Pesanan',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.space2),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(item.name)),
                        Text(_formatRupiah(item.unitPrice * item.quantity)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.space3),
                const Divider(),
                const SizedBox(height: AppSpacing.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      _formatRupiah(totalAmount),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text('Cetak Struk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _openCheckoutDialog() {
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

    final nameController = TextEditingController();
    String? selectedTableName;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isSubmitting = _controller.state.isSubmitting;
            final isDineIn = _controller.state.salesChannel == PosSalesChannel.dineIn;
            final dineInTables = _controller.state.tables
                .where((t) => t.channel == PosSalesChannel.dineIn)
                .toList();

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart_checkout_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text(
                    'Konfirmasi Pesanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Silakan masukkan informasi pesanan untuk menyelesaikan transaksi POS Kasir.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      TextFormField(
                        controller: nameController,
                        enabled: !isSubmitting,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Nama Pelanggan',
                          hintText: 'Nama pelanggan (e.g. Budi)',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0F172A)
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama pelanggan wajib diisi';
                          }
                          if (value.trim().length < 2) {
                            return 'Nama minimal terdiri dari 2 karakter';
                          }
                          return null;
                        },
                      ),
                      if (isDineIn) ...[
                        const SizedBox(height: AppSpacing.space4),
                        dineInTables.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(AppSpacing.space3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red.shade200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
                                    const SizedBox(width: AppSpacing.space2),
                                    Expanded(
                                      child: Text(
                                        'Belum ada meja makan. Silakan buat meja makan di halaman Manajemen Meja terlebih dahulu.',
                                        style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                value: selectedTableName,
                                decoration: InputDecoration(
                                  labelText: 'Pilih Nomor Meja',
                                  hintText: 'Pilih nomor meja',
                                  prefixIcon: const Icon(Icons.table_restaurant_rounded, color: AppColors.primary),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF0F172A)
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                ),
                                items: dineInTables.map((table) {
                                  return DropdownMenuItem<String>(
                                    value: table.label,
                                    child: Text(table.label),
                                  );
                                }).toList(),
                                onChanged: isSubmitting
                                    ? null
                                    : (value) {
                                        setState(() {
                                          selectedTableName = value;
                                        });
                                      },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nomor meja wajib dipilih';
                                  }
                                  return null;
                                },
                              ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (isDineIn && dineInTables.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan buat meja di halaman Manajemen Meja terlebih dahulu.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (formKey.currentState?.validate() ?? false) {
                            setState(() {}); // Show loading inside popup
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(dialogCtx);
                            final customerName = nameController.text.trim();
                            final tableName = isDineIn ? selectedTableName : null;
                            final itemsSnapshot = List<PosOrderLineEntity>.from(_controller.state.orderLines);
                            final totalSnapshot = _controller.grandTotal;

                            try {
                              final success = await _controller.checkout(
                                customerName: customerName,
                                tableName: tableName,
                              );
                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Pesanan berhasil disimpan dan masuk ke list order!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                navigator.pop();
                                
                                // Show receipt after dialog is closed
                                _showReceiptDialog(
                                  customerName: customerName,
                                  tableName: tableName,
                                  items: itemsSnapshot,
                                  totalAmount: totalSnapshot,
                                );
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal menyelesaikan pesanan.'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Gagal: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space3,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Proses Pesanan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openMobileOrderSheet() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _MobileOrderSummaryPage(
          controller: _controller,
          onCheckout: _openCheckoutDialog,
        ),
      ),
    );
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
                  salesChannel: state.salesChannel,
                  onSelectChannel: widget.controller.updateSalesChannel,
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
    if (mounted) {
      Navigator.of(context).pop();
    }
    widget.onCheckout();
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
