import 'package:fe_gangsta_flutter/core/utils/currency_formatter.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/order_totals_card.dart';
import 'package:flutter/material.dart';

class CustomerCheckoutPreviewPage extends StatelessWidget {
  const CustomerCheckoutPreviewPage({
    required this.items,
    required this.orderNote,
    required this.paymentMethod,
    required this.subtotal,
    required this.additionalFee,
    required this.totalPayment,
    super.key,
  });

  final List<CartItemEntity> items;
  final String orderNote;
  final PaymentMethodEntity? paymentMethod;
  final int subtotal;
  final int additionalFee;
  final int totalPayment;

  void _submit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pesanan berhasil dibuat'),
        content: const Text(
          'Order dummy berhasil disubmit. Lanjutkan ke proses pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pesanan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item pesanan', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.space3),
              ...items.map(
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
              Text(orderNote.isEmpty ? '-' : orderNote),
              const SizedBox(height: AppSpacing.space3),
              Text('Metode pembayaran', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.space1),
              Text(paymentMethod?.name ?? '-'),
              const SizedBox(height: AppSpacing.space4),
              OrderTotalsCard(
                subtotal: subtotal,
                additionalFee: additionalFee,
                total: totalPayment,
              ),
              const SizedBox(height: AppSpacing.space4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  child: const Text('Submit Pesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
