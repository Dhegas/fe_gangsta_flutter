import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/data/datasources/membership_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/data/repositories/membership_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/presentation/controllers/membership_list_controller.dart';
import 'package:flutter/material.dart';

// ─── Payment stream mock ───────────────────────────────────────────────────────
class _PaymentItem {
  const _PaymentItem({
    required this.name,
    required this.sub,
    required this.amount,
    required this.isSuccess,
  });
  final String name, sub, amount;
  final bool isSuccess;
}

const _payments = [
  _PaymentItem(
      name: 'Bakso Pak Slamet',
      sub: 'Pro Plan Renewal • 2 mins ago',
      amount: '+Rp199.000',
      isSuccess: true),
  _PaymentItem(
      name: 'Mie Ayam Jakarta',
      sub: 'Basic Plan • 14 mins ago',
      amount: '+Rp99.000',
      isSuccess: true),
  _PaymentItem(
      name: 'Soto Betawi Bang Haji',
      sub: 'Pro Plan • 45 mins ago',
      amount: 'Rp199.000',
      isSuccess: true),
  _PaymentItem(
      name: 'Ayam Geprek Mercon',
      sub: 'Enterprise Plan • 1 hr ago',
      amount: 'Rp349.000',
      isSuccess: true),
];

// ─── Page ──────────────────────────────────────────────────────────────────────
class MembershipListPage extends StatefulWidget {
  const MembershipListPage({super.key});

  @override
  State<MembershipListPage> createState() => _MembershipListPageState();
}

class _MembershipListPageState extends State<MembershipListPage> {
  late final MembershipListController _controller;

  @override
  void initState() {
    super.initState();
    final repo = MembershipRepositoryImpl(MembershipLocalDataSource());
    _controller = MembershipListController(repo)
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

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: _buildAppBar(tt),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
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
                    // ── Page header ───────────────────────────────────
                    _buildPageHeader(tt),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Revenue forecast + MRR row ────────────────────
                    _buildForecastRow(tt),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Subscription architect ────────────────────────
                    Text('Subscription Architect',
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.space4),
                    _buildPlanCards(tt, state.memberships),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Bottom live payments + penetration ─────────────
                    _buildBottomRow(tt),
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
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child:
                const Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Maitre D\' Admin',
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.primary)),
              Text('SAAS COMMANDER',
                  style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary, letterSpacing: 1)),
            ],
          ),
        ],
      ),
      actions: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search members or plans...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
      ],
    );
  }

  // ── Page header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      final titleCol = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership Overview',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 4),
          Text(
              'Elevate and manage the culinary performance of your partner network.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      );

      final buttonsRow = Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Export Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceStrong),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFAB3500), Color(0xFFFF6B35)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create New Plan — Coming Soon')),
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create New Plan'),
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
          ),
        ],
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleCol,
            const SizedBox(height: AppSpacing.space4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: buttonsRow,
            ),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleCol),
          const SizedBox(width: AppSpacing.space4),
          buttonsRow,
        ],
      );
    });
  }

  // ── Revenue forecast row ───────────────────────────────────────────────────
  Widget _buildForecastRow(TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      final chartCard = Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF191C1E).withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
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
                          Text('Revenue Forecast',
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text('Projected earnings for the next 12 months',
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: AppColors.secondary, size: 14),
                          const SizedBox(width: 4),
                          Text('+14.2% YoY',
                              style: tt.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                // Mini bar chart
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: _BarChartPainter(),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL',
                            'AUG', 'SEP', 'OCT']
                        .map((m) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(m,
                                  style: tt.labelSmall
                                      ?.copyWith(color: AppColors.textSecondary)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
      );

      final rightCol = SizedBox(
        width: isMobile ? double.infinity : 180,
        child: Column(
          children: [
              // MRR card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space5),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total MRR',
                        style: tt.labelSmall?.copyWith(
                            color: Colors.white70, letterSpacing: 0.5)),
                    const SizedBox(height: AppSpacing.space2),
                    Text('Rp142 Jt',
                        style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    const SizedBox(height: AppSpacing.space3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text('24 New Today',
                          style: tt.labelSmall
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              // Churn card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF191C1E).withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Churn Rate',
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.space2),
                    Text('1.4%',
                        style: tt.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      children: [
                        const Icon(Icons.trending_down_rounded,
                            size: 14, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('−0.3% vs last month',
                            style: tt.labelSmall
                                ?.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      if (isMobile) {
        return Column(
          children: [
            chartCard,
            const SizedBox(height: AppSpacing.space4),
            rightCol,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: chartCard),
          const SizedBox(width: AppSpacing.space4),
          rightCol,
        ],
      );
    });
  }

  // ── Plan cards row ─────────────────────────────────────────────────────────
  Widget _buildPlanCards(TextTheme tt, List<MembershipEntity> plans) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        return Column(
          children: plans.map((plan) {
            final idx = plans.indexOf(plan);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: idx < plans.length - 1 ? AppSpacing.space4 : 0),
              child: _PlanCard(plan: plan, tt: tt),
            );
          }).toList(),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: plans.map((plan) {
          final idx = plans.indexOf(plan);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: idx < plans.length - 1 ? AppSpacing.space4 : 0),
              child: _PlanCard(plan: plan, tt: tt),
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Bottom row: Live payments + Plan penetration ────────────────────────────
  Widget _buildBottomRow(TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 650;

      final livePaymentCard = Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF191C1E).withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Live Payment Stream',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('View All Ledger',
                        style: tt.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                ..._payments.map((p) => _PaymentRow(item: p, tt: tt)).toList(),
              ],
            ),
      );

      final penetrationCard = SizedBox(
        width: isMobile ? double.infinity : 200,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF191C1E).withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLAN PENETRATION',
                    style: tt.labelSmall?.copyWith(
                        color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: AppSpacing.space4),
                _PenetrationBar(label: 'Professional', pct: 0.72, color: AppColors.primary),
                const SizedBox(height: AppSpacing.space3),
                _PenetrationBar(label: 'Basic', pct: 0.18, color: AppColors.surfaceStrong),
                const SizedBox(height: AppSpacing.space3),
                _PenetrationBar(label: 'Enterprise', pct: 0.10, color: AppColors.secondary),
              ],
            ),
          ),
        );

      if (isMobile) {
        return Column(
          children: [
            livePaymentCard,
            const SizedBox(height: AppSpacing.space4),
            penetrationCard,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: livePaymentCard),
          const SizedBox(width: AppSpacing.space4),
          penetrationCard,
        ],
      );
    });
  }
}

// ─── Plan card ─────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.tt});
  final MembershipEntity plan;
  final TextTheme tt;

  Color get _accent {
    if (plan.name.toLowerCase().contains('pro')) return AppColors.primary;
    if (plan.name.toLowerCase().contains('enterprise')) {
      return const Color(0xFF475569);
    }
    return AppColors.secondary;
  }

  String _fmt(int v) {
    final reversed = v.toString().split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }
    return '\$${chunks.reversed.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: plan.isPopular
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF191C1E)
                  .withOpacity(plan.isPopular ? 0.12 : 0.05),
              blurRadius: plan.isPopular ? 24 : 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    plan.isPopular
                        ? Icons.local_fire_department_rounded
                        : plan.name.toLowerCase().contains('enterprise')
                            ? Icons.corporate_fare_rounded
                            : Icons.restaurant_rounded,
                    color: _accent,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: plan.isPopular
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    plan.isPopular
                        ? 'POPULAR'
                        : plan.name.toLowerCase().contains('enterprise')
                            ? 'GLOBAL'
                            : 'ACTIVE',
                    style: tt.labelSmall?.copyWith(
                      color: plan.isPopular
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(plan.name.replaceAll(' Plan', ''),
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(
              plan.name.toLowerCase().contains('pro')
                  ? 'For high-traffic restaurants'
                  : plan.name.toLowerCase().contains('enterprise')
                      ? 'For multi-chain hospitality'
                      : 'For single venue bistros',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmt(plan.price),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: plan.isPopular ? AppColors.primary : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text('/mo',
                    style: tt.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            ...plan.features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(f,
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: AppSpacing.space5),
            const Divider(color: AppColors.surfaceSoft),
            const SizedBox(height: AppSpacing.space3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT REACH',
                        style: tt.labelSmall?.copyWith(
                            color: AppColors.textSecondary, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                      plan.isPopular
                          ? '3,582'
                          : plan.name.toLowerCase().contains('enterprise')
                              ? '412'
                              : '1,204',
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    plan.isPopular ? '+28%' : '+12%',
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment stream row ────────────────────────────────────────────────────────
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.item, required this.tt});
  final _PaymentItem item;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.isSuccess
                  ? AppColors.secondary.withOpacity(0.1)
                  : AppColors.statusError.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: item.isSuccess ? AppColors.secondary : AppColors.statusError,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(item.sub,
                    style:
                        tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.amount,
                  style: tt.bodyMedium?.copyWith(
                    color: item.isSuccess
                        ? AppColors.textPrimary
                        : AppColors.statusError,
                    fontWeight: FontWeight.w600,
                  )),
              Text(
                item.isSuccess ? 'SUCCESS' : 'FAILED',
                style: tt.labelSmall?.copyWith(
                    color: item.isSuccess
                        ? AppColors.secondary
                        : AppColors.statusError,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Penetration bar ──────────────────────────────────────────────────────────
class _PenetrationBar extends StatelessWidget {
  const _PenetrationBar(
      {required this.label, required this.pct, required this.color});
  final String label;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: tt.bodySmall?.copyWith(color: AppColors.textPrimary)),
            ),
            Text('${(pct * 100).toInt()}%',
                style: tt.labelSmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceSoft,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Bar chart painter ─────────────────────────────────────────────────────────
class _BarChartPainter extends CustomPainter {
  final _heights = const [0.3, 0.4, 0.45, 0.5, 0.55, 0.6, 0.9, 0.85, 0.4, 0.3];

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (_heights.length * 2 - 1);
    for (var i = 0; i < _heights.length; i++) {
      final h = size.height * _heights[i];
      final x = i * barWidth * 2;
      final paint = Paint()
        ..color = (i == 7 || i == 6)
            ? AppColors.primary
            : AppColors.surfaceStrong
        ..style = PaintingStyle.fill;

      // dashed future bars
      if (i >= 8) {
        paint.color = AppColors.surfaceStrong.withOpacity(0.5);
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, barWidth, h),
            const Radius.circular(4));
        canvas.drawRRect(rect, paint);
      } else {
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, barWidth, h),
            const Radius.circular(4));
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter o) => false;
}
