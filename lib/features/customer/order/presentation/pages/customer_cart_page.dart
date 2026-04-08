import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/repositories/order_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/controllers/customer_cart_controller.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/pages/customer_checkout_preview_page.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/cart_item_tile.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/order_totals_card.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/widgets/payment_method_selector.dart';
import 'package:flutter/material.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({required this.initialItems, super.key});

  final List<CartItemEntity> initialItems;

  @override
  State<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage> {
  late final CustomerCartController _controller;

  @override
  void initState() {
    super.initState();
    final repository = OrderRepositoryImpl(OrderLocalDataSource());
    _controller =
        CustomerCartController(
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

  Future<void> _goToCheckoutPreview() async {
    final isSubmitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomerCheckoutPreviewPage(
          items: _controller.state.items,
          orderNote: _controller.state.orderNote,
          paymentMethod: _controller.selectedPaymentMethod,
          subtotal: _controller.subtotal,
          additionalFee: _controller.additionalFee,
          totalPayment: _controller.totalPayment,
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
