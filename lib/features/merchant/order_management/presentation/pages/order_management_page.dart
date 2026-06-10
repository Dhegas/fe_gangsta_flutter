import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/core/services/websocket_service.dart';
import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/data/datasources/order_management_remote_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/data/repositories/order_management_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/presentation/controllers/order_management_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/presentation/state/order_management_state.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_local_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_remote_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/repositories/table_management_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late final OrderManagementController _controller;
  final MerchantNavItem _selectedNav = MerchantNavItem.orders;
  final WebSocketService _wsService = WebSocketService();

  @override
  void initState() {
    super.initState();

    final orderRepo = OrderManagementRepositoryImpl(
      remoteDataSource: OrderManagementRemoteDataSourceImpl(),
    );

    final tableRepo = TableManagementRepositoryImpl(
      remoteDataSource: TableManagementRemoteDataSourceImpl(),
      localDataSource: TableManagementLocalDataSourceImpl(),
    );

    _controller = OrderManagementController(
      orderRepository: orderRepo,
      tableRepository: tableRepo,
    )
      ..addListener(_onControllerChanged)
      ..initialize();

    // Initialize WebSocket connection
    final token = ApiClient.activeToken ?? '';
    final tenantId = ApiClient.activeTenantId ?? '';
    if (token.isNotEmpty && tenantId.isNotEmpty) {
      _wsService.connect(token: token, tenantId: tenantId);
      _wsService.onNewOrderReceived = (orderData) {
        // Play subtle sound feedback
        SystemSound.play(SystemSoundType.click);

        // Silent refresh orders list
        _controller.refreshOrders();

        // Show a premium visual SnackBar notification for the new order
        if (mounted) {
          final orderId = orderData['order_id'] as String?;
          final shortId = orderId != null && orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : 'Baru';
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Colors.white),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🔔 Pesanan Baru Masuk!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'ID Pesanan: #$shortId',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      };
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleNavTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
    } else {
      navigateToMerchantSection(context, item, _selectedNav);
    }
  }

  Color _getStatusTextColor(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
      case 'PROCESSING':
        return isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF0D47A1);
      case 'COMPLETED':
        return isDarkMode ? const Color(0xFF81C784) : const Color(0xFF1B5E20);
      case 'CANCELLED':
        return isDarkMode ? const Color(0xFFE57373) : const Color(0xFFB71C1C);
      default:
        return isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF424242);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFFF3E0);
      case 'PROCESSING':
        return const Color(0xFFE3F2FD);
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELLED':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Future<void> _confirmDeleteOrder(OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Text('Batalkan Pesanan'),
          content: Text(
            'Apakah Anda yakin ingin membatalkan/menghapus pesanan #${order.id.substring(0, 8)}? Aksi ini akan menghapusnya secara permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusError,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _controller.deleteOrder(order.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan'),
              backgroundColor: AppColors.statusSuccess,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _controller.state.errorMessage ?? 'Gagal membatalkan pesanan',
              ),
              backgroundColor: AppColors.statusError,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmCompleteOrder(OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Text('Selesaikan Pesanan'),
          content: Text(
            'Apakah Anda yakin ingin menyelesaikan pesanan #${order.id.substring(0, 8)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSuccess,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _controller.updateOrderStatus(order.id, 'COMPLETED');
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil diselesaikan'),
              backgroundColor: AppColors.statusSuccess,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _controller.state.errorMessage ?? 'Gagal menyelesaikan pesanan',
              ),
              backgroundColor: AppColors.statusError,
            ),
          );
        }
      }
    }
  }

  void _showReceiptDialog(OrderEntity order, String tableName) {
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
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'Struk Transaksi',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'ID: #${order.id.substring(0, 8).toUpperCase()}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.space4),
                const Divider(),
                const SizedBox(height: AppSpacing.space3),
                _buildReceiptRow('Status', order.status.toUpperCase()),
                if (order.queueNumber != null && order.queueNumber!.isNotEmpty)
                  _buildReceiptRow('Nomor Antrian', order.queueNumber!),
                _buildReceiptRow('Pelanggan', order.customerName.isNotEmpty ? order.customerName : 'Pelanggan'),
                _buildReceiptRow('Meja', tableName),
                if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
                  _buildReceiptRow('Metode Pembayaran', order.paymentMethod!),
                const SizedBox(height: AppSpacing.space3),
                const Divider(),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'Item Pesanan',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.space2),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(item.menuName)),
                        Text(CurrencyFormatter.toRupiah(item.subtotal.toInt())),
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
                      CurrencyFormatter.toRupiah(order.totalPrice.toInt()),
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

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final merchantName = ApiClient.activeTenantName ?? 'Toko';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1120;
        final isTablet = constraints.maxWidth >= 760;

        return Scaffold(
          bottomNavigationBar: isDesktop
              ? null
              : MerchantBottomNav(
                  selectedItem: _selectedNav,
                  onTapItem: _handleNavTap,
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  MerchantSidebar(
                    merchantName: merchantName,
                    merchantRoleLabel: 'Partner Lead',
                    selectedItem: _selectedNav,
                    onTapItem: _handleNavTap,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MerchantTopBar(
                          onSearchChanged: (_) {},
                          isCompact: !isTablet,
                          showSearchBar: false,
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orders Management',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kelola pesanan masuk untuk merchant Anda',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).scaffoldBackgroundColor == const Color(0xFF0F172A)
                                            ? const Color(0xFF94A3B8)
                                            : AppColors.textMuted,
                                      ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _controller.initialize(),
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh Pesanan',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        Expanded(
                          child: _buildBodyContent(state, isTablet, isDesktop),
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

  Widget _buildBodyContent(
    OrderManagementState state,
    bool isTablet,
    bool isDesktop,
  ) {
    if (state.isLoading && state.orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.statusError,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space4),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => _controller.initialize(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Belum Ada Pesanan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua pesanan baru dari pelanggan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: AppSpacing.space5),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => _controller.initialize(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      itemCount: state.orders.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.space4,
        mainAxisSpacing: AppSpacing.space4,
        mainAxisExtent: 395,
      ),
      itemBuilder: (context, index) {
        final order = state.orders[index];
        final tableName = state.tables[order.diningTablesId] ?? 'Take Away';
        final formattedDate =
            DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

        return Card(
          margin: EdgeInsets.zero,
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tableName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
                                ),
                              ),
                              if (order.queueNumber != null && order.queueNumber!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    order.queueNumber!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (order.customerName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Pemesan: ${order.customerName}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? const Color(0xFFE2E8F0) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? _getStatusBgColor(order.status).withValues(alpha: 0.16) : _getStatusBgColor(order.status),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Row(
                  children: [
                    Text(
                      'ID: #${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ID Pesanan #${order.id} disalin ke clipboard',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.print_rounded, size: 18, color: AppColors.primary),
                      onPressed: () => _showReceiptDialog(order, tableName),
                      tooltip: 'Cetak Struk',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: order.items.length,
                    itemBuilder: (context, idx) {
                      final item = order.items[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.menuName,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.toRupiah(
                                    item.subtotal.toInt(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode ? const Color(0xFFE2E8F0) : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            if (item.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 24.0,
                                  top: 2,
                                ),
                                child: Text(
                                  'Catatan: ${item.notes}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.toRupiah(order.totalPrice.toInt()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (order.status.toUpperCase() != 'COMPLETED') ...[
                  const SizedBox(height: AppSpacing.space3),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade200),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _confirmDeleteOrder(order),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text(
                            'Batalkan',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusSuccess,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          onPressed: () => _confirmCompleteOrder(order),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text(
                            'Selesai',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.space3),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDarkMode ? AppColors.statusSuccess : const Color(0xFF1B5E20),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pesanan Selesai',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? AppColors.statusSuccess : const Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
