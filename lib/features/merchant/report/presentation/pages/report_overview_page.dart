import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/datasources/report_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/repositories/report_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_period.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_sales_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/usecases/get_merchant_report.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/controllers/report_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/state/report_state.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';

class ReportOverviewPage extends StatefulWidget {
  const ReportOverviewPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<ReportOverviewPage> createState() => _ReportOverviewPageState();
}

class _ReportOverviewPageState extends State<ReportOverviewPage> {
  late final ReportController _controller;
  final MerchantNavItem _selectedNav = MerchantNavItem.reports;

  @override
  void initState() {
    super.initState();
    final usecase = GetMerchantReport(
      ReportRepositoryImpl(ReportLocalDataSourceImpl()),
    );
    _controller = ReportController(getMerchantReport: usecase)..addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1120;
        final isTablet = constraints.maxWidth >= 760;

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: AppColors.surfaceNeutral,
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
                      merchantName: 'Bistro Moderne',
                      merchantRoleLabel: 'Owner',
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
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          _HeaderControls(
                            state: state,
                            onPickCustom: () => _controller.pickCustomRange(context),
                            onSelectPreset: _controller.selectPreset,
                            onToggleComparison: _controller.toggleComparison,
                            onExport: _onExport,
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          const TabBar(
                            isScrollable: true,
                            tabs: [
                              Tab(text: 'Ringkasan'),
                              Tab(text: 'Penjualan'),
                              Tab(text: 'Keuangan'),
                              Tab(text: 'Pelanggan'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Expanded(
                            child: state.isLoading || state.report == null
                                ? const Center(child: CircularProgressIndicator())
                                : TabBarView(
                                    children: [
                                      _ExecutiveSummaryTab(state: state, report: state.report!),
                                      _SalesReportTab(report: state.report!),
                                      _FinancialReportTab(report: state.report!),
                                      _CustomerInsightsTab(report: state.report!),
                                    ],
                                  ),
                          ),
                        ],
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

  void _onExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export $format sedang diproses...')),
    );
  }

  void _handleNavTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }

    navigateToMerchantSection(context, item, MerchantNavItem.reports);
  }
}

class _HeaderControls extends StatelessWidget {
  const _HeaderControls({
    required this.state,
    required this.onSelectPreset,
    required this.onPickCustom,
    required this.onToggleComparison,
    required this.onExport,
  });

  final ReportState state;
  final ValueChanged<ReportPreset> onSelectPreset;
  final VoidCallback onPickCustom;
  final ValueChanged<bool> onToggleComparison;
  final ValueChanged<String> onExport;

  @override
  Widget build(BuildContext context) {
    final rangeLabel =
        '${state.rangeStart.day}/${state.rangeStart.month}/${state.rangeStart.year} - ${state.rangeEnd.day}/${state.rangeEnd.month}/${state.rangeEnd.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Report & Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacing.space2),
          ...ReportPreset.values
              .where((preset) => preset != ReportPreset.custom)
              .map(
                (preset) => ChoiceChip(
                  label: Text(preset.label),
                  selected: state.preset == preset,
                  onSelected: (_) => onSelectPreset(preset),
                ),
              ),
          ActionChip(
            label: const Text('Kustom'),
            avatar: const Icon(Icons.date_range_outlined, size: 16),
            onPressed: onPickCustom,
          ),
          Chip(label: Text(rangeLabel), backgroundColor: AppColors.surfaceNeutral),
          FilterChip(
            label: const Text('Bandingkan dengan periode sebelumnya'),
            selected: state.isComparing,
            onSelected: onToggleComparison,
          ),
          FilledButton.tonalIcon(
            onPressed: () => onExport('CSV'),
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('CSV'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => onExport('Excel'),
            icon: const Icon(Icons.grid_on_outlined),
            label: const Text('Excel'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => onExport('PDF'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveSummaryTab extends StatelessWidget {
  const _ExecutiveSummaryTab({required this.state, required this.report});

  final ReportState state;
  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: [
            _MetricCard(
              title: 'Gross Revenue',
              value: _currency(summary.grossRevenue),
              subtitle: 'Total penjualan kotor',
              icon: Icons.payments_outlined,
            ),
            _MetricCard(
              title: 'Net Revenue',
              value: _currency(summary.netRevenue),
              subtitle: 'Uang bersih diterima',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _MetricCard(
              title: 'Total Orders',
              value: '${summary.totalOrders}',
              subtitle: 'Jumlah transaksi',
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              title: 'AOV',
              value: _currency(summary.averageOrderValue),
              subtitle: 'Rata-rata nilai pesanan',
              icon: Icons.stacked_line_chart_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Grafik Tren Penjualan 7 Hari',
          subtitle: 'Menjawab performa bisnis dari hari ke hari.',
          child: Column(
            children: [
              _TrendBars(values: summary.trend),
              if (state.isComparing) ...[
                const SizedBox(height: AppSpacing.space2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Perbandingan MoM: ${summary.periodComparisonPercent.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: summary.periodComparisonPercent >= 0
                              ? AppColors.statusSuccess
                              : AppColors.statusError,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SalesReportTab extends StatelessWidget {
  const _SalesReportTab({required this.report});

  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final sales = report.sales;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _Panel(
          title: 'Penjualan Berdasarkan Waktu',
          subtitle: 'Rincian per jam, hari, minggu, bulan.',
          child: Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              _KpiChip(label: 'Per Jam', value: _currency(sales.salesByTime.hourly)),
              _KpiChip(label: 'Harian', value: _currency(sales.salesByTime.daily)),
              _KpiChip(label: 'Mingguan', value: _currency(sales.salesByTime.weekly)),
              _KpiChip(label: 'Bulanan', value: _currency(sales.salesByTime.monthly)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Metode Pembayaran',
          subtitle: 'Porsi e-Wallet, transfer, kartu, tunai.',
          child: _SegmentList(items: sales.paymentMethods),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Status Pesanan',
          subtitle: 'Berhasil, dibatalkan, refund.',
          child: _SegmentList(items: sales.orderStatuses),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Penjualan Berdasarkan Channel',
          subtitle: 'Offline store vs online delivery.',
          child: _SegmentList(items: sales.channels),
        ),
      ],
    );
  }
}

class _FinancialReportTab extends StatelessWidget {
  const _FinancialReportTab({required this.report});

  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final financial = report.financial;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _Panel(
          title: 'Rincian Biaya',
          subtitle: 'Biaya platform, pengiriman, pajak.',
          child: Column(
            children: financial.fees
                .map(
                  (fee) => _InfoRow(
                    label: fee.label,
                    value: _currency(fee.amount),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Settlement / Payouts',
          subtitle: 'Status pencairan dana ke rekening merchant.',
          child: Column(
            children: financial.payouts
                .map(
                  (payout) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(payout.dateLabel),
                    subtitle: Text(_currency(payout.amount)),
                    trailing: Chip(label: Text(payout.status)),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Refund',
          subtitle: 'Rekap dana yang dikembalikan ke pelanggan.',
          child: _InfoRow(
            label: 'Total Refund (${financial.refundCount} transaksi)',
            value: _currency(financial.refundAmount),
          ),
        ),
      ],
    );
  }
}

class _CustomerInsightsTab extends StatelessWidget {
  const _CustomerInsightsTab({required this.report});

  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final customer = report.customerInsight;
    final total = customer.newCustomers + customer.returningCustomers;
    final newRatio = total == 0 ? 0.0 : customer.newCustomers / total;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _Panel(
          title: 'New vs Returning Customers',
          subtitle: 'Indikator retensi pelanggan merchant.',
          child: Column(
            children: [
              LinearProgressIndicator(
                value: newRatio,
                minHeight: 10,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceStrong,
              ),
              const SizedBox(height: AppSpacing.space2),
              _InfoRow(
                label: 'Pelanggan Baru',
                value: '${customer.newCustomers}',
              ),
              _InfoRow(
                label: 'Pelanggan Kembali',
                value: '${customer.returningCustomers}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Top Spenders',
          subtitle: 'Pelanggan dengan pembelanjaan tertinggi.',
          child: Column(
            children: customer.topSpenders
                .map(
                  (spender) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceStrong,
                      child: Text(spender.name.isEmpty ? '?' : spender.name.substring(0, 1)),
                    ),
                    title: Text(spender.name),
                    subtitle: Text('${spender.totalOrders} transaksi'),
                    trailing: Text(
                      _currency(spender.totalSpent),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.space2),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (value) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: (value / max) * 130,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SegmentList extends StatelessWidget {
  const _SegmentList({required this.items});

  final List<SalesSegmentEntity> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Column(
                children: [
                  _InfoRow(
                    label: '${item.label} (${item.count})',
                    value: _currency(item.amount),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : item.amount / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceStrong,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: AppColors.surfaceNeutral,
      label: Text('$label: $value'),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.space3),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: AppSpacing.space2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

String _currency(double value) {
  final fixed = value.toStringAsFixed(0);
  final chunks = <String>[];
  for (int end = fixed.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end);
    chunks.insert(0, fixed.substring(start, end));
  }
  return 'Rp ${chunks.join('.')}';
}
