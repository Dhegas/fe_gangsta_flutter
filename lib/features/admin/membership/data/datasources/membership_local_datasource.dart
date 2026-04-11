import 'package:fe_gangsta_flutter/features/admin/membership/data/models/membership_model.dart';

class MembershipLocalDataSource {
  Future<List<MembershipModel>> getMemberships() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return const [
      MembershipModel(
        id: 'basic',
        name: 'Basic Plan',
        price: 99000,
        billingCycle: 'monthly',
        features: [
          'Digital Menu',
          'Self Order QR',
          'POS Kasir Dasar',
          'Laporan Harian',
        ],
        isPopular: false,
      ),
      MembershipModel(
        id: 'pro',
        name: 'Pro Plan',
        price: 199000,
        billingCycle: 'monthly',
        features: [
          'Semua Fitur Basic',
          'Manajemen Table',
          'Laporan Penjualan Lengkap',
          'Pengaturan Karyawan (2 Akun)',
        ],
        isPopular: true,
      ),
      MembershipModel(
        id: 'enterprise',
        name: 'Enterprise Plan',
        price: 349000,
        billingCycle: 'monthly',
        features: [
          'Semua Fitur Pro',
          'Unlimited Akun Kasir',
          'Integrasi Printer Dapur',
          'Priority Support 24/7',
        ],
        isPopular: false,
      ),
    ];
  }
}
