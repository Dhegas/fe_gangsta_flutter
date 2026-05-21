import 'dart:ui';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/repositories/order_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/order_totals_card.dart';
import 'package:flutter/material.dart';

class CustomerCheckoutPreviewPage extends StatefulWidget {
  const CustomerCheckoutPreviewPage({
    required this.items,
    required this.orderNote,
    required this.paymentMethod,
    required this.subtotal,
    required this.additionalFee,
    required this.totalPayment,
    required this.tenantSlug,
    this.tableId,
    super.key,
  });

  final List<CartItemEntity> items;
  final String orderNote;
  final PaymentMethodEntity? paymentMethod;
  final int subtotal;
  final int additionalFee;
  final int totalPayment;
  final String tenantSlug;
  final String? tableId;

  @override
  State<CustomerCheckoutPreviewPage> createState() => _CustomerCheckoutPreviewPageState();
}

class _CustomerCheckoutPreviewPageState extends State<CustomerCheckoutPreviewPage> {
  final OrderRepository _orderRepository = OrderRepositoryImpl(
    OrderLocalDataSource(),
    OrderRemoteDataSource(ApiClient()),
  );

  bool _isLoading = false;

  Future<void> _submitOrder() async {
    setState(() {
      _isLoading = true;
    });

    final diningTableId = (widget.tableId == null || widget.tableId!.isEmpty)
        ? '2cdf85fc-6698-48dd-a989-82b313a5e2ed'
        : widget.tableId!;

    try {
      final order = await _orderRepository.placeOrder(
        tenantSlug: widget.tenantSlug,
        diningTablesId: diningTableId,
        items: widget.items,
        orderNote: widget.orderNote,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show beautiful premium success receipt invoice dialog
      await _showSuccessInvoiceDialog(order);

    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.statusError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.all(AppSpacing.space4),
      ),
    );
  }

  Future<void> _showSuccessInvoiceDialog(OrderEntity order) async {
    final textTheme = Theme.of(context).textTheme;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  // Success Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.statusSuccess,
                          size: 64,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          'Pemesanan Berhasil!',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          'Pesanan Anda sedang diproses oleh dapur.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Invoice Details
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            dialogContext, 
                            'ID Pesanan', 
                            order.id.substring(0, 8).toUpperCase(),
                            isBold: true,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          _buildDetailRow(
                            dialogContext, 
                            'Status', 
                            order.status,
                            valueColor: AppColors.primary,
                            isBold: true,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          _buildDetailRow(
                            dialogContext, 
                            'Nomor Meja', 
                            order.diningTablesId.length > 8 
                                ? order.diningTablesId.substring(0, 8) 
                                : order.diningTablesId,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          _buildDetailRow(
                            dialogContext, 
                            'Waktu', 
                            _formatDateTime(order.createdAt),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          
                          const DashedDivider(color: AppColors.surfaceStrong),
                          const SizedBox(height: AppSpacing.space4),
                          
                          Text(
                            'Rincian Menu',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            style: textTheme.bodySmall?.copyWith(
                                              color: AppColors.textMuted,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.toRupiah(item.subtotal),
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
                                'Total Pembayaran',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.toRupiah(order.totalPrice),
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
                  
                  // Footer Actions
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
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                        ),
                        onPressed: () {
                          // Close dialog first
                          Navigator.of(dialogContext).pop();
                          // Pop the checkout preview page returning true to clear the cart
                          Navigator.of(context).pop(true);
                        },
                        child: const Text(
                          'Kembali ke Menu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    BuildContext context, 
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Ringkasan Pesanan')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item pesanan', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.space3),
                  ...widget.items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.quantity} x ${CurrencyFormatter.toRupiah(item.price)}',
                      ),
                      trailing: Text(
                        CurrencyFormatter.toRupiah(item.price * item.quantity),
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text('Catatan', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.space1),
                  Text(widget.orderNote.isEmpty ? '-' : widget.orderNote),
                  const SizedBox(height: AppSpacing.space3),
                  Text('Metode pembayaran', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.space1),
                  Text(widget.paymentMethod?.name ?? '-'),
                  const SizedBox(height: AppSpacing.space4),
                  OrderTotalsCard(
                    subtotal: widget.subtotal,
                    additionalFee: widget.additionalFee,
                    total: widget.totalPayment,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitOrder,
                      child: const Text('Submit Pesanan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space6,
                      vertical: AppSpacing.space5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          'Memproses pesanan Anda...',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
