import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';

// ─── Mock tenant health data ───────────────────────────────────────────────────
class _TenantRow {
  const _TenantRow({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.tier,
    required this.tierColor,
    required this.uptime,
    required this.uptimeOk,
    required this.subscriptionLabel,
    required this.subscriptionColor,
  });
  final String initials;
  final String name;
  final String subtitle;
  final String tier;
  final Color tierColor;
  final String uptime;
  final bool uptimeOk;
  final String subscriptionLabel;
  final Color subscriptionColor;
}

const _tenants = [
  _TenantRow(
    initials: 'BS',
    name: 'Bakso Pak Slamet',
    subtitle: 'Cabang Utama • Aktif',
    tier: 'ENTERPRISE',
    tierColor: Color(0xFFFF6B35),
    uptime: '99.98%',
    uptimeOk: true,
    subscriptionLabel: 'Current',
    subscriptionColor: Color(0xFF2ECC71),
  ),
  _TenantRow(
    initials: 'MA',
    name: 'Mie Ayam Jakarta',
    subtitle: 'West Side Mall • Idle',
    tier: 'PROFESSIONAL',
    tierColor: Color(0xFF2ECC71),
    uptime: '100.0%',
    uptimeOk: true,
    subscriptionLabel: 'Expires 3d',
    subscriptionColor: Color(0xFFF1C40F),
  ),
  _TenantRow(
    initials: 'SB',
    name: 'Soto Betawi Bang Haji',
    subtitle: 'Terminal 4 • Offline',
    tier: 'BASIC',
    tierColor: Color(0xFF94A3B8),
    uptime: '94.20%',
    uptimeOk: false,
    subscriptionLabel: 'Failed',
    subscriptionColor: Color(0xFFEF4444),
  ),
];

// ─── Page ──────────────────────────────────────────────────────────────────────
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    final repository = DashboardRepositoryImpl(DashboardLocalDataSource());
    _controller = DashboardController(repository)
      ..addListener(_rebuild)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  String _fmt(int v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)} Jt';
    final s = v.toString().split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < s.length; i += 3) {
      chunks.add(s.skip(i).take(3).toList().reversed.join());
    }
    return 'Rp ${chunks.reversed.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: _buildAppBar(tt),
      body: SafeArea(
        child: state.isLoading || state.stats == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space6,
                  AppSpacing.space4,
                  AppSpacing.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page title  ──────────────────────────────────
                    _buildPageHeader(tt, state.stats!.totalTenants),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Hero KPI row  ────────────────────────────────
                    _buildKpiRow(tt, state.stats!),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Revenue chart placeholder ────────────────────
                    _buildChartCard(tt),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Tenant Status Overview ───────────────────────
                    _buildTenantStatusOverview(tt, state.stats!),
                  ],
                ),
              ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(TextTheme tt) {
    return AppBar(
      backgroundColor: AppColors.surfaceBase,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CulinaryOS',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text('SUPER ADMIN',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  )),
            ],
          ),
        ],
      ),
      actions: [
        // Global search bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.space3),
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: AppSpacing.space2),
                  Text('Global search…  (Ctrl+K)',
                      style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.space2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text('⌘ K', style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Page header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(TextTheme tt, int totalTenants) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Center',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Overseeing $totalTenants active culinary partners globally.',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        // CTA button with gradient
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFAB3500), Color(0xFFFF6B35)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Merchant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space5,
                vertical: AppSpacing.space3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── KPI Row ─────────────────────────────────────────────────────────────────
  Widget _buildKpiRow(TextTheme tt, stats) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left BIG card
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space6),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF191C1E).withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM REVENUE',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _fmt(stats.totalRevenue),
                        style: tt.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 56, color: AppColors.surfaceStrong),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '+12.4% vs last month',
                      style: tt.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                Row(
                  children: [
                    _PillTag(label: 'Weekly Forecast: Rp620k'),
                    const SizedBox(width: AppSpacing.space2),
                    _PillTag(label: 'Subscription Yield: 88%'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        // Right dark NETWORK card
        SizedBox(
          width: 180,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F2E),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF191C1E).withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NETWORK GROWTH',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  '${stats.totalTenants}',
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified Merchants',
                  style: tt.bodySmall?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: AppSpacing.space5),
                // Avatar stack
                SizedBox(
                  height: 28,
                  child: Stack(
                    children: [
                      _Avatar(label: 'BS', color: AppColors.primary),
                      Positioned(
                        left: 18,
                        child: _Avatar(label: 'MA', color: AppColors.secondary),
                      ),
                      Positioned(
                        left: 36,
                        child: _Avatar(label: '+${stats.newTenantsThisMonth}',
                            color: const Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Chart card ─────────────────────────────────────────────────────────────
  Widget _buildChartCard(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Global Revenue Trends',
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Daily transaction volume across all tenants',
                        style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              // Tab pills
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    _TabPill(label: 'Revenue', active: true),
                    _TabPill(label: 'Orders', active: false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          // Sketch wave chart using CustomPaint
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _WaveChartPainter(),
            ),
          ),
        ],
      ),
    );
  }


  // ── Tenant Status Overview ─────────────────────────────────────────────────
  Widget _buildTenantStatusOverview(TextTheme tt, stats) {
    final total = (stats.totalTenants as int?) ?? 4;
    final active = (stats.activeMemberships as int?) ?? 3;
    final pending = (stats.newTenantsThisMonth as int?) ?? 1;
    final unpaidRaw = total - active - pending;
    final unpaid = unpaidRaw < 0 ? 0 : unpaidRaw;

    final activePct  = total > 0 ? active  / total : 0.0;
    final pendingPct = total > 0 ? pending / total : 0.0;
    final unpaidPct  = total > 0 ? unpaid  / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tenant Status Overview',
                      style: tt.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Real-time breakdown of all registered merchants',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('View All',
                    style: tt.labelMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.primary),
              ]),
            ),
          ]),
          const SizedBox(height: AppSpacing.space5),

          // 3 stat cards
          LayoutBuilder(builder: (ctx, con) {
            final narrow = con.maxWidth < 500;
            final cards = [
              _StatusStatCard(
                label: 'ACTIVE',
                count: active,
                total: total,
                color: AppColors.secondary,
                icon: Icons.check_circle_rounded,
                sublabel: 'Subscriptions current & operational',
                pct: activePct,
              ),
              _StatusStatCard(
                label: 'PENDING',
                count: pending,
                total: total,
                color: AppColors.tertiary,
                icon: Icons.hourglass_top_rounded,
                sublabel: 'Awaiting activation or approval',
                pct: pendingPct,
              ),
              _StatusStatCard(
                label: 'UNPAID',
                count: unpaid,
                total: total,
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
                if ((activePct + pendingPct + unpaidPct) < 1.0)
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
            _StatusDot(color: AppColors.secondary,
                label: '$active Active (${(activePct * 100).toStringAsFixed(0)}%)'),
            _StatusDot(color: AppColors.tertiary,
                label: '$pending Pending (${(pendingPct * 100).toStringAsFixed(0)}%)'),
            _StatusDot(color: AppColors.statusError,
                label: '$unpaid Unpaid (${(unpaidPct * 100).toStringAsFixed(0)}%)'),
          ]),
        ],
      ),
    );
  }
}


// ─── Supporting widgets ────────────────────────────────────────────────────────

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

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(label,
          style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1C1F2E), width: 2),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceBase : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: active
            ? [
                BoxShadow(
                    color: const Color(0xFF191C1E).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [],
      ),
      child: Text(label,
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          )),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TenantHealthRow extends StatelessWidget {
  const _TenantHealthRow({required this.tenant, required this.tt});
  final _TenantRow tenant;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space6, vertical: AppSpacing.space4),
          child: Row(
            children: [
              // Merchant cell
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(tenant.initials,
                          style: tt.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tenant.name,
                              style: tt.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(tenant.subtitle,
                              style: tt.labelSmall?.copyWith(
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tenant.tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    tenant.tier,
                    style: tt.labelSmall?.copyWith(
                      color: tenant.tierColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Uptime
              Expanded(
                flex: 2,
                child: Text(
                  tenant.uptime,
                  style: tt.bodyMedium?.copyWith(
                    color: tenant.uptimeOk
                        ? AppColors.textPrimary
                        : AppColors.statusError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Subscription
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tenant.subscriptionColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: tenant.subscriptionColor.withOpacity(0.4),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(tenant.subscriptionLabel,
                        style: tt.bodyMedium
                            ?.copyWith(color: tenant.subscriptionColor)),
                  ],
                ),
              ),
              // Actions
              SizedBox(
                width: 48,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: AppColors.textSecondary, size: 18),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceSoft),
      ],
    );
  }
}

// ─── Wave chart painter ────────────────────────────────────────────────────────
class _WaveChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.15),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Control points that mimic the wavy chart in the design
    final pts = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.72),
      Offset(size.width * 0.28, size.height * 0.68),
      Offset(size.width * 0.42, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.58, size.height * 0.55),
      Offset(size.width * 0.68, size.height * 0.2),
      Offset(size.width * 0.82, size.height * 0.28),
      Offset(size.width, size.height * 0.32),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_WaveChartPainter o) => false;
}
