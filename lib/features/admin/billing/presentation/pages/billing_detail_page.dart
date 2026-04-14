import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Billing detail page ───────────────────────────────────────────────────────
class BillingDetailPage extends StatelessWidget {
  const BillingDetailPage({super.key, required this.billing});

  final BillingEntity billing;

  Color get _statusColor {
    switch (billing.status) {
      case 'paid':
        return AppColors.secondary;
      case 'unpaid':
        return AppColors.tertiary;
      case 'overdue':
        return AppColors.statusError;
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtDate(DateTime dt) => DateFormat('dd MMMM yyyy').format(dt);

  String _fmtRupiah(int amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Invoice Detail',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Invoice header card ──────────────────────────────────
              _buildInvoiceHeaderCard(tt),
              const SizedBox(height: AppSpacing.space4),

              // ── Tenant info ──────────────────────────────────────────
              _buildSectionCard(
                tt,
                title: 'Tenant Information',
                icon: Icons.store_outlined,
                child: _buildTenantInfo(tt),
              ),
              const SizedBox(height: AppSpacing.space4),

              // ── Billing detail ───────────────────────────────────────
              _buildSectionCard(
                tt,
                title: 'Billing Detail',
                icon: Icons.receipt_long_outlined,
                child: _buildBillingDetail(tt),
              ),
              const SizedBox(height: AppSpacing.space6),

              // ── Action buttons ───────────────────────────────────────
              _buildActions(context, tt),
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Invoice header card ────────────────────────────────────────────────────
  Widget _buildInvoiceHeaderCard(TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAB3500), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: Colors.white70, size: 20),
              const SizedBox(width: AppSpacing.space2),
              Text(billing.invoiceNumber,
                  style: tt.labelLarge?.copyWith(color: Colors.white70)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  billing.status.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            _fmtRupiah(billing.amount),
            style: tt.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -1),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(billing.tenantName,
              style: tt.bodyLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSpacing.space1),
          Text('Due: ${_fmtDate(billing.dueDate)}',
              style: tt.bodySmall?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }

  // ── Section card ────────────────────────────────────────────────────────────
  Widget _buildSectionCard(
    TextTheme tt, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.space2),
            Text(title,
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.space4),
          const Divider(color: AppColors.surfaceSoft, height: 1),
          const SizedBox(height: AppSpacing.space4),
          child,
        ],
      ),
    );
  }

  // ── Tenant info ────────────────────────────────────────────────────────────
  Widget _buildTenantInfo(TextTheme tt) {
    return Column(
      children: [
        _DetailRow(
          label: 'Tenant ID',
          value: billing.tenantId,
          tt: tt,
        ),
        _DetailRow(
          label: 'Tenant Name',
          value: billing.tenantName,
          tt: tt,
        ),
        _DetailRow(
          label: 'Subscription Plan',
          value: billing.plan,
          tt: tt,
          valueColor: billing.plan.toLowerCase() == 'enterprise'
              ? AppColors.primary
              : billing.plan.toLowerCase() == 'pro'
                  ? AppColors.secondary
                  : AppColors.textPrimary,
        ),
      ],
    );
  }

  // ── Billing detail ──────────────────────────────────────────────────────────
  Widget _buildBillingDetail(TextTheme tt) {
    return Column(
      children: [
        _DetailRow(
          label: 'Invoice Number',
          value: billing.invoiceNumber,
          tt: tt,
        ),
        _DetailRow(
          label: 'Amount',
          value: _fmtRupiah(billing.amount),
          tt: tt,
          fontWeight: FontWeight.w700,
        ),
        _DetailRow(
          label: 'Due Date',
          value: _fmtDate(billing.dueDate),
          tt: tt,
        ),
        _DetailRow(
          label: 'Payment Date',
          value: billing.paidAt != null
              ? _fmtDate(billing.paidAt!)
              : '—',
          tt: tt,
          valueColor:
              billing.paidAt != null ? AppColors.secondary : AppColors.textMuted,
        ),
        _StatusRow(
          label: 'Status',
          status: billing.status,
          statusColor: _statusColor,
          tt: tt,
        ),
      ],
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context, TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 480;

      final resendBtn = OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Resend Invoice — Coming Soon')),
        ),
        icon: const Icon(Icons.send_outlined, size: 16),
        label: const Text('Resend Invoice'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceStrong),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
      );

      final markPaidBtn = DecoratedBox(
        decoration: BoxDecoration(
          color: billing.status == 'paid'
              ? AppColors.surfaceStrong
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ElevatedButton.icon(
          onPressed: billing.status == 'paid'
              ? null
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mark as Paid — Coming Soon')),
                  ),
          icon: Icon(
            billing.status == 'paid'
                ? Icons.check_circle_rounded
                : Icons.payment_rounded,
            size: 16,
          ),
          label: Text(billing.status == 'paid' ? 'Already Paid' : 'Mark as Paid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
          ),
        ),
      );

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            markPaidBtn,
            const SizedBox(height: AppSpacing.space3),
            resendBtn,
          ],
        );
      }

      return Row(children: [
        Expanded(child: resendBtn),
        const SizedBox(width: AppSpacing.space3),
        Expanded(child: markPaidBtn),
      ]);
    });
  }
}

// ─── Detail row widget ─────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.tt,
    this.valueColor,
    this.fontWeight,
  });

  final String label;
  final String value;
  final TextTheme tt;
  final Color? valueColor;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodySmall?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: fontWeight ?? FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status row widget ─────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.status,
    required this.statusColor,
    required this.tt,
  });

  final String label;
  final String status;
  final Color statusColor;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              status.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                  color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
