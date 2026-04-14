import 'package:fe_gangsta_flutter/features/admin/billing/data/models/billing_model.dart';

class BillingLocalDataSource {
  Future<List<BillingModel>> getBillings() async {
    await Future.delayed(const Duration(milliseconds: 750));

    final now = DateTime.now();

    return [
      BillingModel(
        id: 'b001',
        tenantId: 't4',
        tenantName: 'Ayam Geprek Mercon',
        plan: 'Enterprise',
        amount: 349000,
        status: 'paid',
        dueDate: DateTime(now.year, now.month, 5),
        paidAt: DateTime(now.year, now.month, 3),
        invoiceNumber: 'INV-2026-04-001',
      ),
      BillingModel(
        id: 'b002',
        tenantId: 't1',
        tenantName: 'Bakso Pak Slamet',
        plan: 'Pro',
        amount: 199000,
        status: 'paid',
        dueDate: DateTime(now.year, now.month, 10),
        paidAt: DateTime(now.year, now.month, 8),
        invoiceNumber: 'INV-2026-04-002',
      ),
      BillingModel(
        id: 'b003',
        tenantId: 't2',
        tenantName: 'Mie Ayam Jakarta',
        plan: 'Basic',
        amount: 99000,
        status: 'unpaid',
        dueDate: DateTime(now.year, now.month, now.day + 3),
        paidAt: null,
        invoiceNumber: 'INV-2026-04-003',
      ),
      BillingModel(
        id: 'b004',
        tenantId: 't3',
        tenantName: 'Soto Betawi Bang Haji',
        plan: 'Pro',
        amount: 199000,
        status: 'overdue',
        dueDate: DateTime(now.year, now.month, now.day - 5),
        paidAt: null,
        invoiceNumber: 'INV-2026-04-004',
      ),
      BillingModel(
        id: 'b005',
        tenantId: 't5',
        tenantName: 'Nasi Campur Bu Wati',
        plan: 'Basic',
        amount: 99000,
        status: 'paid',
        dueDate: DateTime(now.year, now.month - 1, 28),
        paidAt: DateTime(now.year, now.month - 1, 26),
        invoiceNumber: 'INV-2026-03-005',
      ),
      BillingModel(
        id: 'b006',
        tenantId: 't6',
        tenantName: 'Warung Makan Sederhana',
        plan: 'Pro',
        amount: 199000,
        status: 'pending',
        dueDate: DateTime(now.year, now.month, now.day + 7),
        paidAt: null,
        invoiceNumber: 'INV-2026-04-006',
      ),
      BillingModel(
        id: 'b007',
        tenantId: 't7',
        tenantName: 'Sate Madura Pak Amin',
        plan: 'Enterprise',
        amount: 349000,
        status: 'paid',
        dueDate: DateTime(now.year, now.month, 15),
        paidAt: DateTime(now.year, now.month, 14),
        invoiceNumber: 'INV-2026-04-007',
      ),
      BillingModel(
        id: 'b008',
        tenantId: 't8',
        tenantName: 'Kedai Kopi & Mie',
        plan: 'Basic',
        amount: 99000,
        status: 'overdue',
        dueDate: DateTime(now.year, now.month, now.day - 10),
        paidAt: null,
        invoiceNumber: 'INV-2026-04-008',
      ),
    ];
  }
}
