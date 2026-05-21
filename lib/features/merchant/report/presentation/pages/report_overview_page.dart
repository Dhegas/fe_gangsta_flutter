import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/datasources/report_remote_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/data/repositories/report_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/merchant_report_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/entities/report_period.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/domain/usecases/get_merchant_report.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/controllers/report_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/report/presentation/state/report_state.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      ReportRepositoryImpl(ReportRemoteDataSourceImpl()),
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
          length: 3,
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
                              Tab(text: 'Ringkasan & Tren'),
                              Tab(text: 'Menu Terlaris'),
                              Tab(text: 'Performa Meja'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Expanded(
                            child: state.errorMessage.isNotEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: AppColors.statusError,
                                          size: 48,
                                        ),
                                        const SizedBox(height: AppSpacing.space3),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.space6,
                                          ),
                                          child: Text(
                                            state.errorMessage,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.space3),
                                        FilledButton.icon(
                                          onPressed: _controller.load,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Coba Lagi'),
                                        ),
                                      ],
                                    ),
                                  )
                                : state.isLoading || state.report == null
                                    ? const Center(child: CircularProgressIndicator())
                                    : TabBarView(
                                        children: [
                                          _ExecutiveSummaryTab(state: state, report: state.report!),
                                          _TopMenusTab(report: state.report!),
                                          _OrdersByTableTab(report: state.report!),
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
    final revenue = report.revenue;
    final totalRevenue = revenue.totalRevenue;
    final totalOrders = revenue.totalOrders;
    final aov = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: [
            _MetricCard(
              title: 'Gross Revenue',
              value: _currency(totalRevenue),
              subtitle: 'Total pendapatan kotor',
              icon: Icons.payments_outlined,
            ),
            _MetricCard(
              title: 'Total Orders',
              value: '$totalOrders',
              subtitle: 'Jumlah transaksi sukses',
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              title: 'AOV (Average Order Value)',
              value: _currency(aov),
              subtitle: 'Rata-rata nilai per order',
              icon: Icons.stacked_line_chart_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Grafik Tren Penjualan Harian',
          subtitle: 'Menampilkan fluktuasi pendapatan harian dalam grafik.',
          child: _TrendBars(entries: report.dailySummary.summary),
        ),
        const SizedBox(height: AppSpacing.space3),
        _Panel(
          title: 'Rincian Penjualan Harian',
          subtitle: 'Daftar transaksi harian secara detail.',
          child: report.dailySummary.summary.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space3),
                    child: Text('Tidak ada rincian transaksi harian'),
                  ),
                )
              : Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: AppColors.surfaceStrong,
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      children: [
                        _tableHeader(context, 'Tanggal'),
                        _tableHeader(context, 'Order'),
                        _tableHeader(context, 'Total Pendapatan'),
                        _tableHeader(context, 'AOV'),
                      ],
                    ),
                    ...report.dailySummary.summary.map((entry) {
                      String dayLabel = entry.date;
                      try {
                        final dt = DateTime.parse(entry.date);
                        dayLabel = DateFormat('dd MMM yyyy').format(dt);
                      } catch (_) {}

                      return TableRow(
                        children: [
                          _tableCell(dayLabel),
                          _tableCell('${entry.totalOrders}'),
                          _tableCell(_currency(entry.totalRevenue)),
                          _tableCell(_currency(entry.avgOrderValue)),
                        ],
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text),
    );
  }
}

class _TopMenusTab extends StatelessWidget {
  const _TopMenusTab({required this.report});

  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final menus = report.topMenus.menus;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _Panel(
          title: 'Menu Terlaris',
          subtitle: 'Peringkat menu berdasarkan kuantitas terjual.',
          child: menus.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space3),
                    child: Text('Tidak ada data menu terlaris'),
                  ),
                )
              : Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: AppColors.surfaceStrong,
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      children: [
                        _tableHeader(context, 'Rank'),
                        _tableHeader(context, 'Nama Menu'),
                        _tableHeader(context, 'Jumlah'),
                        _tableHeader(context, 'Total Penjualan'),
                      ],
                    ),
                    ...menus.map((menu) {
                      return TableRow(
                        children: [
                          _tableCell('#${menu.rank}'),
                          _tableCell(menu.menuName),
                          _tableCell('${menu.totalQty}'),
                          _tableCell(_currency(menu.totalSold)),
                        ],
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text),
    );
  }
}

class _OrdersByTableTab extends StatelessWidget {
  const _OrdersByTableTab({required this.report});

  final MerchantReportEntity report;

  @override
  Widget build(BuildContext context) {
    final tables = report.ordersByTable.tables;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _Panel(
          title: 'Performa Meja',
          subtitle: 'Data pesanan dan nominal penjualan berdasarkan meja.',
          child: tables.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space3),
                    child: Text('Tidak ada data performa meja'),
                  ),
                )
              : Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: AppColors.surfaceStrong,
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      children: [
                        _tableHeader(context, 'Rank'),
                        _tableHeader(context, 'Nomor Meja'),
                        _tableHeader(context, 'Order'),
                        _tableHeader(context, 'Total Pendapatan'),
                      ],
                    ),
                    ...tables.map((table) {
                      return TableRow(
                        children: [
                          _tableCell('#${table.rank}'),
                          _tableCell('Meja ${table.tableNumber}'),
                          _tableCell('${table.totalOrders}'),
                          _tableCell(_currency(table.totalRevenue)),
                        ],
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
  const _TrendBars({required this.entries});

  final List<DailySummaryEntryEntity> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('Tidak ada data tren harian'),
        ),
      );
    }

    final maxRevenue = entries.map((e) => e.totalRevenue).reduce((a, b) => a > b ? a : b);
    final displayMax = maxRevenue > 0 ? maxRevenue : 1.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final percentage = (entry.totalRevenue / displayMax).clamp(0.0, 1.0);
          final barHeight = percentage * 130;

          String dayLabel = entry.date;
          try {
            final dt = DateTime.parse(entry.date);
            dayLabel = DateFormat('dd MMM').format(dt);
          } catch (_) {}

          return SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: '${_currency(entry.totalRevenue)} (${entry.totalOrders} order)',
                    child: Container(
                      height: barHeight > 4 ? barHeight : 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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

String _currency(double value) {
  final fixed = value.toStringAsFixed(0);
  final chunks = <String>[];
  for (int end = fixed.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end);
    chunks.insert(0, fixed.substring(start, end));
  }
  return 'Rp ${chunks.join('.')}';
}
