import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/data/datasources/billing_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/data/repositories/billing_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/presentation/controllers/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Billing overview page ─────────────────────────────────────────────────────
class BillingOverviewPage extends StatefulWidget {
  const BillingOverviewPage({super.key});

  @override
  State<BillingOverviewPage> createState() => _BillingOverviewPageState();
}

class _BillingOverviewPageState extends State<BillingOverviewPage> {
  late final BillingController _controller;
  final TextEditingController _searchCtrl = TextEditingController();
  final _platformFeeCtrl = TextEditingController(text: '2.5');
  final _taxCtrl = TextEditingController(text: '11.0');

  static const _filterTabs = [
    ('all', 'All'),
    ('paid', 'Paid'),
    ('unpaid', 'Unpaid'),
    ('overdue', 'Overdue'),
    ('pending', 'Pending'),
  ];

  @override
  void initState() {
    super.initState();
    final repo = BillingRepositoryImpl(BillingLocalDataSource());
    _controller = BillingController(repo)
      ..addListener(_rebuild)
      ..initialize();
    _searchCtrl.addListener(() => _controller.updateSearch(_searchCtrl.text));
  }

  @override
  void dispose() {
    _platformFeeCtrl.dispose();
    _taxCtrl.dispose();
    _searchCtrl.dispose();
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
                slivers: [
                  // ── Summary metrics ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildSummaryMetrics(tt, state.billings),
                  ),

                  // ── Page header ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4,
                          AppSpacing.space5,
                          AppSpacing.space4,
                          AppSpacing.space4),
                      child: _buildPageHeader(tt),
                    ),
                  ),

                  // ── Billing Configuration ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4,
                          0,
                          AppSpacing.space4,
                          AppSpacing.space4),
                      child: _buildConfigCard(tt),
                    ),
                  ),

                  // ── Filter tabs ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildFilterTabs(tt, state),
                  ),

                  // ── Invoice list ──────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space4,
                        AppSpacing.space3,
                        AppSpacing.space4,
                        AppSpacing.space16),
                    sliver: _buildInvoiceList(tt),
                  ),
                ],
              ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceBase,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search invoice, tenant, or plan...',
            prefixIcon: const Icon(Icons.search,
                color: AppColors.textSecondary, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.space4),
          child: IconButton(
            icon: const Icon(Icons.download_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Export',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export billing — Coming Soon')),
            ),
          ),
        ),
      ],
    );
  }

  // ── Summary metrics ────────────────────────────────────────────────────────
  Widget _buildSummaryMetrics(TextTheme tt, List<BillingEntity> billings) {
    final paid = billings.where((b) => b.status == 'paid').toList();
    final unpaid = billings.where((b) => b.status == 'unpaid').toList();
    final overdue = billings.where((b) => b.status == 'overdue').toList();

    final totalRevenue =
        paid.fold<int>(0, (sum, b) => sum + b.amount);
    final totalUnpaid =
        unpaid.fold<int>(0, (sum, b) => sum + b.amount);
    final totalOverdue =
        overdue.fold<int>(0, (sum, b) => sum + b.amount);

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 520;

      final cells = [
        _SummaryCell(
          label: 'TOTAL COLLECTED',
          value: _fmtRupiah(totalRevenue),
          sub: '${paid.length} invoices paid',
          subIcon: Icons.check_circle_outline_rounded,
          subColor: AppColors.secondary,
          accentColor: AppColors.secondary,
        ),
        _SummaryCell(
          label: 'UNPAID INVOICES',
          value: _fmtRupiah(totalUnpaid),
          sub: '${unpaid.length} awaiting payment',
          subIcon: Icons.hourglass_top_rounded,
          subColor: AppColors.tertiary,
          accentColor: AppColors.tertiary,
        ),
        _SummaryCell(
          label: 'OVERDUE AMOUNT',
          value: _fmtRupiah(totalOverdue),
          sub: '${overdue.length} past due date',
          subIcon: Icons.warning_amber_rounded,
          subColor: AppColors.statusError,
          accentColor: AppColors.statusError,
        ),
      ];

      return Container(
        color: AppColors.surfaceBase,
        padding: EdgeInsets.symmetric(
            vertical: AppSpacing.space5,
            horizontal: narrow ? AppSpacing.space4 : 0),
        child: narrow
            ? Column(
                children: cells
                    .expand<Widget>((c) => [c, const SizedBox(height: AppSpacing.space4)])
                    .toList()
                  ..removeLast(),
              )
            : IntrinsicHeight(
                child: Row(children: [
                  Expanded(child: cells[0]),
                  const _VDivider(),
                  Expanded(child: cells[1]),
                  const _VDivider(),
                  Expanded(child: cells[2]),
                ]),
              ),
      );
    });
  }

  // ── Page header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 560;

      final titleCol = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Billing & Invoices',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text('Monitor subscription payments and invoice status.',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      );

      final exportBtn = DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFAB3500), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Generate Invoice — Coming Soon')),
          ),
          icon: const Icon(Icons.receipt_long_outlined, size: 16),
          label: const Text('Generate Invoice'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
          ),
        ),
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleCol,
            const SizedBox(height: AppSpacing.space3),
            exportBtn,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleCol),
          exportBtn,
        ],
      );
    });
  }

  // ── Filter tabs ────────────────────────────────────────────────────────────
  Widget _buildFilterTabs(TextTheme tt, state) {
    final currentFilter = _controller.state.filterStatus;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Row(
        children: _filterTabs.map((tab) {
          final (key, label) = tab;
          final isActive = currentFilter == key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: GestureDetector(
              onTap: () => _controller.updateFilter(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surfaceStrong,
                  ),
                ),
                child: Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color:
                        isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Configuration Card ──────────────────────────────────────────────────────
  Widget _buildConfigCard(TextTheme tt) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.space2),
              Text('Billing & Taxes Config', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          _buildTextFieldRow(tt, 'Platform Fee (%)', _platformFeeCtrl, 'Ex: 2.5'),
          const Divider(color: AppColors.surfaceSoft, height: 24),
          _buildTextFieldRow(tt, 'Default Tax Rate (%)', _taxCtrl, 'Ex: 11.0'),
          const SizedBox(height: AppSpacing.space3),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Config Saved'))),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Save Config'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(TextTheme tt, String label, TextEditingController ctrl, String hint) {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 600;
      final labelWidget = Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600));
      final inputWidget = SizedBox(
        height: 36,
        child: TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodyMedium?.copyWith(color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: const BorderSide(color: AppColors.surfaceStrong)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: const BorderSide(color: AppColors.surfaceStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: const BorderSide(color: AppColors.primary)),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
          ),
        ),
      );

      if (narrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [labelWidget, const SizedBox(height: AppSpacing.space2), inputWidget],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: labelWidget),
          Expanded(flex: 3, child: inputWidget),
        ],
      );
    });
  }

  // ── Invoice list ────────────────────────────────────────────────────────────
  Widget _buildInvoiceList(TextTheme tt) {
    final items = _controller.visibleBillings;

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48, color: AppColors.surfaceStrong),
              const SizedBox(height: AppSpacing.space3),
              Text('Tidak ada invoice ditemukan.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space3),
          child: _InvoiceCard(billing: items[index]),
        ),
        childCount: items.length,
      ),
    );
  }

  String _fmtRupiah(int amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }
}

// ─── Summary cell ──────────────────────────────────────────────────────────────
class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.sub,
    required this.subIcon,
    required this.subColor,
    required this.accentColor,
  });

  final String label, value, sub;
  final IconData subIcon;
  final Color subColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: tt.labelSmall?.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.space2),
            Text(value,
                style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.space2),
            Row(children: [
              Icon(subIcon, size: 14, color: subColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(sub,
                    style: tt.labelSmall?.copyWith(color: subColor)),
              ),
            ]),
          ],
        ),
    );
  }
}

// ─── Vertical divider ──────────────────────────────────────────────────────────
class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 60, color: AppColors.surfaceStrong);
}

// ─── Invoice card ──────────────────────────────────────────────────────────────
class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.billing});

  final BillingEntity billing;

  Color get _statusColor {
    switch (billing.status) {
      case 'paid':
        return AppColors.secondary;
      case 'unpaid':
        return AppColors.tertiary;
      case 'overdue':
        return AppColors.statusError;
      case 'pending':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (billing.status) {
      case 'paid':
        return 'PAID';
      case 'unpaid':
        return 'UNPAID';
      case 'overdue':
        return 'OVERDUE';
      case 'pending':
        return 'PENDING';
      default:
        return billing.status.toUpperCase();
    }
  }

  IconData get _statusIcon {
    switch (billing.status) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'unpaid':
        return Icons.hourglass_top_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      case 'pending':
        return Icons.pending_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color get _planAccent {
    switch (billing.plan.toLowerCase()) {
      case 'enterprise':
        return AppColors.primary;
      case 'pro':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

  String _fmtRupiah(int amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
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
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final statusBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_statusIcon, size: 12, color: _statusColor),
            const SizedBox(width: 4),
            Text(
              _statusLabel,
              style: tt.labelSmall?.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ]),
        );

        final planBadge = Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _planAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            billing.plan.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: _planAccent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      billing.tenantName,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  statusBadge,
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(billing.invoiceNumber,
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.space3),
              Row(children: [
                planBadge,
                const Spacer(),
                Text(
                  _fmtRupiah(billing.amount),
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ]),
              const SizedBox(height: AppSpacing.space2),
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Due: ${_fmtDate(billing.dueDate)}',
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textSecondary)),
                if (billing.paidAt != null) ...[
                  const SizedBox(width: AppSpacing.space3),
                  Icon(Icons.check_rounded,
                      size: 12, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text('Paid: ${_fmtDate(billing.paidAt!)}',
                      style: tt.labelSmall
                          ?.copyWith(color: AppColors.secondary)),
                ],
              ]),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: icon + info ────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        billing.tenantName,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    planBadge,
                  ]),
                  const SizedBox(height: AppSpacing.space1),
                  Row(children: [
                    Text(billing.invoiceNumber,
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: AppSpacing.space3),
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(_fmtDate(billing.dueDate),
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    if (billing.paidAt != null) ...[
                      const SizedBox(width: AppSpacing.space3),
                      Icon(Icons.check_rounded,
                          size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text('Paid ${_fmtDate(billing.paidAt!)}',
                          style: tt.labelSmall
                              ?.copyWith(color: AppColors.secondary)),
                    ],
                  ]),
                ],
              ),
            ),

            // ── Right: amount + status ────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmtRupiah(billing.amount),
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.space1),
                statusBadge,
              ],
            ),
          ],
        );
      }),
    );
  }
}
