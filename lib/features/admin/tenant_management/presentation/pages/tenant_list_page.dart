import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/repositories/tenant_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/controllers/tenant_list_controller.dart';
import 'package:flutter/material.dart';

// ─── Static data ──────────────────────────────────────────────────────────────
const _kTenantDesc = {
  't1': 'Spesialis bakso sapi premium dengan kuah kaldu segar. Sudah berdiri sejak 1995 dan melayani ribuan pelanggan setia di Jakarta Selatan setiap harinya.',
  't2': 'Mie ayam legendaris dengan cita rasa autentik Jakarta. Tersedia menu spesial topping jamur dan pangsit goreng yang renyah dan lezat setiap hari.',
  't3': 'Soto Betawi original dengan santan kental dan daging sapi pilihan. Cita rasa khas Betawi yang sudah teruji puluhan tahun, kini hadir di dua lokasi.',
  't4': 'Ayam geprek super pedas dengan sambal mercon legendaris. Cocok untuk pecinta kuliner pedas yang ingin sensasi berbeda dan tidak terlupakan.',
};

const _kTierGradients = {
  'enterprise': [Color(0xFFFF6B35), Color(0xFFAB3500)],
  'pro':        [Color(0xFF2ECC71), Color(0xFF1A9A50)],
  'basic':      [Color(0xFF64748B), Color(0xFF475569)],
};

// ─── Page ──────────────────────────────────────────────────────────────────────
class TenantListPage extends StatefulWidget {
  const TenantListPage({super.key});

  @override
  State<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends State<TenantListPage> {
  late final TenantListController _controller;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = TenantRepositoryImpl(TenantLocalDataSource());
    _controller = TenantListController(repo)
      ..addListener(_rebuild)
      ..initialize();
    _searchCtrl.addListener(() => _controller.updateSearch(_searchCtrl.text));
  }

  @override
  void dispose() {
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
    final visible = _controller.visibleTenants;
    final all = _controller.tenants;
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
                  // ── 3 top metrics ─────────────────────────────────────────
                  SliverToBoxAdapter(child: _buildTopMetrics(tt, all)),

                  // ── Health radar ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4, AppSpacing.space4,
                          AppSpacing.space4, 0),
                      child: _buildHealthRadar(tt, all),
                    ),
                  ),

                  // ── Directory header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4, AppSpacing.space5,
                          AppSpacing.space4, AppSpacing.space3),
                      child: _buildDirectoryHeader(tt),
                    ),
                  ),

                  // ── Grid of cards ─────────────────────────────────────────
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text('Tidak ada merchant ditemukan.',
                            style: tt.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4, 0,
                          AppSpacing.space4, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _MerchantCard(tenant: visible[i]),
                          childCount: visible.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          crossAxisSpacing: AppSpacing.space4,
                          mainAxisSpacing: AppSpacing.space4,
                          mainAxisExtent: 310,
                        ),
                      ),
                    ),

                  // ── Pagination ────────────────────────────────────────────
                  SliverToBoxAdapter(
                      child: _buildPagination(tt, visible.length)),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space12)),
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
            hintText: 'Search merchants, tiers, or status...',
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
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ── Top 3 metrics ──────────────────────────────────────────────────────────
  Widget _buildTopMetrics(TextTheme tt, List<TenantEntity> tenants) {
    final activeCount = tenants.where((t) => t.status == 'active').length;
    final inactiveCount = tenants.where((t) => t.status == 'inactive').length;

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 500;
      final cells = [
        _MetricCell(
          label: 'TOTAL ACTIVE TENANTS',
          value: '$activeCount',
          sub: '+12% from last month',
          subIcon: Icons.trending_up_rounded,
          subColor: AppColors.secondary,
        ),
        _MetricCell(
          label: 'PENDING APPROVALS',
          value: '$inactiveCount',
          sub: 'Average wait time: 4.2h',
          subIcon: Icons.access_time_rounded,
          subColor: AppColors.textSecondary,
        ),
        const _MetricCell(
          label: 'MONTHLY CHURN RATE',
          value: '0.8%',
          sub: 'Well below industry target (2%)',
          subIcon: Icons.check_circle_outline_rounded,
          subColor: AppColors.secondary,
        ),
      ];

      return Container(
        color: AppColors.surfaceBase,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space5,
            horizontal: narrow ? AppSpacing.space4 : 0),
        child: narrow
            ? Column(
                children: cells
                    .expand((c) => [c, const SizedBox(height: AppSpacing.space4)])
                    .toList()
                  ..removeLast(),
              )
            : IntrinsicHeight(
                child: Row(children: [
                  cells[0],
                  const _Vdivider(),
                  cells[1],
                  const _Vdivider(),
                  cells[2],
                ]),
              ),
      );
    });
  }

  // ── Tenant Status Overview (replaces Health Radar) ─────────────────────────
  Widget _buildHealthRadar(TextTheme tt, List<TenantEntity> tenants) {
    final realTotal = tenants.length;
    final active = tenants.where((t) => t.status == 'active').length;
    final pending = tenants.where((t) => t.status == 'pending').length;
    final unpaidRaw = realTotal - active - pending;
    final unpaid = unpaidRaw < 0 ? 0 : unpaidRaw;

    final actTotal = realTotal == 0 ? 1 : realTotal; // safe divisor
    final activePct = active / actTotal;
    final pendingPct = pending / actTotal;
    final unpaidPct = unpaid / actTotal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF191C1E).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(builder: (ctx, con) {
            final narrow = con.maxWidth < 440;
            return narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tenant Status Overview',
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text('Subscription and operational status distribution',
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tenant Status Overview',
                                style: tt.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                                'Subscription and operational status distribution',
                                style: tt.bodySmall?.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('View Report',
                              style: tt.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward,
                              size: 14, color: AppColors.primary),
                        ]),
                      ),
                    ],
                  );
          }),
          const SizedBox(height: AppSpacing.space5),

          // 3 stat cards
          LayoutBuilder(builder: (ctx, con) {
            final narrow = con.maxWidth < 500;
            final cards = [
              _StatusStatCard(
                label: 'ACTIVE',
                count: active,
                total: realTotal,
                color: AppColors.secondary,
                icon: Icons.check_circle_rounded,
                sublabel: 'Subscriptions current & operational',
                pct: activePct,
              ),
              _StatusStatCard(
                label: 'PENDING',
                count: pending,
                total: realTotal,
                color: AppColors.tertiary,
                icon: Icons.hourglass_top_rounded,
                sublabel: 'Awaiting activation or approval',
                pct: pendingPct,
              ),
              _StatusStatCard(
                label: 'UNPAID',
                count: unpaid,
                total: realTotal,
                color: AppColors.statusError,
                icon: Icons.warning_rounded,
                sublabel: 'Payment overdue or subscription lapsed',
                pct: unpaidPct,
              ),
            ];
            return narrow
                ? Column(
                    children: cards
                        .expand<Widget>((c) =>
                            [c, const SizedBox(height: AppSpacing.space3)])
                        .toList()
                      ..removeLast(),
                  )
                : Row(children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(child: cards[1]),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(child: cards[2]),
                  ]);
          }),
          const SizedBox(height: AppSpacing.space5),

          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: 8,
              child: Row(children: [
                if (activePct > 0)
                  Expanded(
                      flex: (activePct * 100).round(),
                      child: Container(color: AppColors.secondary)),
                if (pendingPct > 0)
                  Expanded(
                      flex: (pendingPct * 100).round(),
                      child: Container(color: AppColors.tertiary)),
                if (unpaidPct > 0)
                  Expanded(
                      flex: (unpaidPct * 100).round(),
                      child: Container(color: AppColors.statusError)),
                if (activePct + pendingPct + unpaidPct < 1.0)
                  Expanded(
                      flex: ((1 - activePct - pendingPct - unpaidPct) * 100)
                          .round(),
                      child: Container(color: AppColors.surfaceSoft)),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),

          // Legend
          Wrap(spacing: AppSpacing.space5, runSpacing: AppSpacing.space2,
              children: [
            _LegendDot(color: AppColors.secondary,
                label: '$active Active (${(activePct * 100).toStringAsFixed(0)}%)'),
            _LegendDot(color: AppColors.tertiary,
                label: '$pending Pending (${(pendingPct * 100).toStringAsFixed(0)}%)'),
            _LegendDot(color: AppColors.statusError,
                label: '$unpaid Unpaid (${(unpaidPct * 100).toStringAsFixed(0)}%)'),
          ]),
        ],
      ),
    );
  }

  // ── Directory header ───────────────────────────────────────────────────────
  Widget _buildDirectoryHeader(TextTheme tt) {
    return LayoutBuilder(builder: (context, con) {
      final narrow = con.maxWidth < 440;
      final addBtn = DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFAB3500), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Merchant — Coming Soon')),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Merchant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      );

      final filterBtn = OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.tune_rounded, size: 16),
        label: const Text('Filter'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceStrong),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      );

      return narrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Merchant Directory',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.space3),
              Row(children: [
                Expanded(child: filterBtn),
                const SizedBox(width: AppSpacing.space2),
                Expanded(child: addBtn),
              ]),
            ])
          : Row(children: [
              Text('Merchant Directory',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              filterBtn,
              const SizedBox(width: AppSpacing.space2),
              addBtn,
            ]);
    });
  }

  // ── Pagination ─────────────────────────────────────────────────────────────
  Widget _buildPagination(TextTheme tt, int count) {
    return Container(
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
      child: Row(children: [
        Flexible(
          child: Text('Showing 1–$count of $count merchants',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: AppSpacing.space4),
        const _PageBtn(label: '‹', enabled: false),
        const SizedBox(width: AppSpacing.space2),
        const _PageBtn(label: '1', active: true),
        const SizedBox(width: AppSpacing.space2),
        const _PageBtn(label: '2'),
        const SizedBox(width: AppSpacing.space2),
        const _PageBtn(label: '3'),
        const SizedBox(width: AppSpacing.space2),
        const _PageBtn(label: '›'),
      ]),
    );
  }
}

// ─── Supporting widgets ────────────────────────────────────────────────────────

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.sub,
    required this.subIcon,
    required this.subColor,
  });

  final String label, value, sub;
  final IconData subIcon;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: tt.labelSmall?.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.space2),
            Text(value,
                style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
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
      ),
    );
  }
}

class _Vdivider extends StatelessWidget {
  const _Vdivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 60, color: AppColors.surfaceStrong);
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}

// ─── Merchant card ─────────────────────────────────────────────────────────────
class _MerchantCard extends StatelessWidget {
  const _MerchantCard({required this.tenant});

  final TenantEntity tenant;

  Color get _tierColor {
    switch (tenant.subscriptionPlan.toLowerCase()) {
      case 'enterprise':
        return AppColors.primary;
      case 'pro':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  List<Color> get _gradientColors =>
      _kTierGradients[tenant.subscriptionPlan.toLowerCase()] ??
      [const Color(0xFF64748B), const Color(0xFF475569)];

  Color get _statusColor =>
      tenant.status == 'active' ? AppColors.secondary : AppColors.statusError;

  String get _initials {
    final parts = tenant.name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return tenant.name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final desc = _kTenantDesc[tenant.id] ??
        'Merchant kuliner terdaftar pada platform CulinaryOS. Melayani pelanggan setiap hari dengan menu pilihan terbaik.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header ────────────────────────────────────────
          SizedBox(
            height: 130,
            child: Stack(
              children: [
                // Background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradientColors,
                      ),
                    ),
                  ),
                ),
                // Watermark icon
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(Icons.storefront_rounded, size: 110,
                      color: Colors.white.withValues(alpha: 0.10)),
                ),
                // Tier badge – top left
                Positioned(
                  top: AppSpacing.space3,
                  left: AppSpacing.space3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(tenant.subscriptionPlan,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                // Options – top right
                Positioned(
                  top: AppSpacing.space2,
                  right: AppSpacing.space2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_horiz,
                        color: Colors.white, size: 16),
                  ),
                ),
                // Avatar + status – bottom left
                Positioned(
                  bottom: AppSpacing.space3,
                  left: AppSpacing.space4,
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(_initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                              color: _statusColor.withValues(alpha: 0.45),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                            tenant.status == 'active' ? 'Active' : 'Inactive',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(tenant.name,
                      style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.space1),
                  // Owner
                  Row(children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(tenant.ownerName,
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.space3),
                  // Description
                  Expanded(
                    child: Text(desc,
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary, height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  // Bottom: ID + tier badge
                  Row(children: [
                    Text('ID: ${tenant.id}',
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _tierColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(tenant.subscriptionPlan.toUpperCase(),
                          style: tt.labelSmall?.copyWith(
                              color: _tierColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination button ─────────────────────────────────────────────────────────
class _PageBtn extends StatelessWidget {
  const _PageBtn(
      {required this.label, this.active = false, this.enabled = true});

  final String label;
  final bool active, enabled;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(label,
          style: tt.labelMedium?.copyWith(
            color: active
                ? Colors.white
                : enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}

class _StatusStatCard extends StatelessWidget {
  const _StatusStatCard({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
    required this.sublabel,
    required this.pct,
  });

  final String label, sublabel;
  final int count, total;
  final Color color;
  final IconData icon;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(label,
                  style: tt.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ),
          ]),
          const SizedBox(height: AppSpacing.space3),
          Text('$count',
              style: tt.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -1)),
          Text('of $total merchants',
              style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(sublabel,
              style: tt.labelSmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

