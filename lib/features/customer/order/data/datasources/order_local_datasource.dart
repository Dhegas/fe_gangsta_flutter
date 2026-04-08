import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';

class OrderLocalDataSource {
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
        id: 'debit',
        name: 'Kartu Debit',
        description: 'Pembayaran via mesin EDC',
        adminFee: 2000,
      ),
    ];
  }

  Future<int> getServiceFee() async {
    return 2000;
  }
}
