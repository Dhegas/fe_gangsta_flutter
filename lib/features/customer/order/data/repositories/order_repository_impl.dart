import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remoteDataSource);

  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    return const [
      PaymentMethodEntity(
        id: 'cash',
        name: 'Bayar Tunai',
        description: 'Bayar langsung di kasir',
        adminFee: 0,
      ),
      PaymentMethodEntity(
        id: 'qris',
        name: 'QRIS',
        description: 'Scan QRIS dari aplikasi e-wallet',
        adminFee: 1000,
      ),
      PaymentMethodEntity(
        id: 'transfer_bank',
        name: 'Transfer Bank',
        description: 'Transfer via ATM/Mobile Banking',
        adminFee: 2500,
      ),
      PaymentMethodEntity(
        id: 'e_wallet',
        name: 'E-Wallet',
        description: 'OVO, GoPay, Dana, LinkAja',
        adminFee: 1500,
      ),
      PaymentMethodEntity(
        id: 'kartu_kredit',
        name: 'Kartu Kredit / Debit',
        description: 'Pembayaran via mesin EDC / online',
        adminFee: 2000,
      ),
      PaymentMethodEntity(
        id: 'minimarket',
        name: 'Minimarket',
        description: 'Bayar di Alfamart / Indomaret',
        adminFee: 2500,
      ),
    ];
  }

  @override
  Future<int> getServiceFee() async {
    return 2000;
  }

  @override
  Future<OrderEntity> placeOrder({
    required String tenantSlug,
    required String diningTablesId,
    required List<CartItemEntity> items,
    required String orderNote,
    required String paymentMethod,
  }) async {
    final mappedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'menu_id': item.id,
        'quantity': item.quantity,
        'notes': index == 0 ? orderNote : '',
      };
    }).toList();

    String backendPaymentMethod = 'CASH';
    switch (paymentMethod.toLowerCase()) {
      case 'qris':
        backendPaymentMethod = 'QRIS';
        break;
      case 'transfer_bank':
        backendPaymentMethod = 'TRANSFER_BANK';
        break;
      case 'e_wallet':
        backendPaymentMethod = 'E_WALLET';
        break;
      case 'kartu_kredit':
      case 'debit':
        backendPaymentMethod = 'KARTU_KREDIT';
        break;
      case 'minimarket':
        backendPaymentMethod = 'MINIMARKET';
        break;
      case 'cash':
      default:
        backendPaymentMethod = 'CASH';
        break;
    }

    return _remoteDataSource.placeOrder(
      tenantSlug: tenantSlug,
      diningTablesId: diningTablesId,
      items: mappedItems,
      paymentMethod: backendPaymentMethod,
    );
  }

  @override
  Future<OrderEntity> placeGuestOrder({
    required String tenantSlug,
    required String diningTableId,
    required List<CartItemEntity> items,
    required String orderNote,
    required GuestCustomerEntity guest,
  }) async {
    final mappedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'menuId': item.id,
        'quantity': item.quantity,
        'notes': index == 0 ? orderNote : '',
      };
    }).toList();

    final resultOrder = await _remoteDataSource.placeGuestOrder(
      tenantSlug: tenantSlug,
      diningTableId: diningTableId,
      items: mappedItems,
      fullName: guest.fullName,
      phoneNumber: guest.phoneNumber,
      email: guest.email,
      password: guest.password,
    );

    // Reconstruct full item lists locally for structural receipt presentation
    final orderItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return OrderItemEntity(
        id: '',
        menuId: item.id,
        menuName: item.name,
        quantity: item.quantity,
        unitPrice: item.price,
        subtotal: item.price * item.quantity,
        notes: index == 0 ? orderNote : '',
      );
    }).toList();

    return OrderEntity(
      id: resultOrder.id,
      tenantId: resultOrder.tenantId,
      userId: resultOrder.userId,
      diningTablesId: resultOrder.diningTablesId,
      status: resultOrder.status,
      totalPrice: resultOrder.totalPrice,
      createdAt: resultOrder.createdAt,
      updatedAt: resultOrder.updatedAt,
      items: orderItems,
      accessToken: resultOrder.accessToken,
    );
  }

  @override
  Future<List<OrderEntity>> getOrderHistory({
    required String tenantId,
    required String tenantSlug,
  }) async {
    return _remoteDataSource.getOrderHistory(
      tenantId: tenantId,
      tenantSlug: tenantSlug,
    );
  }

  @override
  Future<OrderEntity> getOrderDetails({
    required String tenantId,
    required String tenantSlug,
    required String orderId,
  }) async {
    return _remoteDataSource.getOrderDetails(
      tenantId: tenantId,
      tenantSlug: tenantSlug,
      orderId: orderId,
    );
  }
}
