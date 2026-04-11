import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/widgets/stat_summary_card.dart';
import 'package:flutter/material.dart';

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
      ..addListener(_onControllerUpdated)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerUpdated)
      ..dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    setState(() {});
  }

  String _formatCurrency(int value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} Jt';
    }
    final reversed = value.toString().split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }
    return 'Rp ${chunks.reversed.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNeutral,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Platform Overview',
              style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: AppColors.textPrimary,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.space1),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space4),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || state.stats == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Hero Banner ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B35), // primary
                            Color(0xFFFF8C5A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.x2l),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang,',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space1),
                                Text(
                                  'Admin Platform',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.space3,
                                    vertical: AppSpacing.space1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  child: Text(
                                    '${state.stats!.activeMemberships} merchant aktif hari ini',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.bar_chart_rounded,
                            size: 80,
                            color: Colors.white24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // ── Section Label ──────────────────────────────────
                    Text(
                      'Statistik Platform',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),

                    // ── Stat Cards Grid ────────────────────────────────
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: screenWidth < 600 ? 240 : 280,
                        mainAxisSpacing: AppSpacing.space3,
                        crossAxisSpacing: AppSpacing.space3,
                        mainAxisExtent: 180,
                      ),
                      children: [
                        StatSummaryCard(
                          title: 'Total Tenant',
                          value: '${state.stats!.totalTenants}',
                          icon: Icons.storefront_outlined,
                          color: AppColors.primary,
                          trendValue: '+12%',
                        ),
                        StatSummaryCard(
                          title: 'Langganan Aktif',
                          value: '${state.stats!.activeMemberships}',
                          icon: Icons.workspace_premium_outlined,
                          color: AppColors.secondary,
                          trendValue: '+5%',
                        ),
                        StatSummaryCard(
                          title: 'Total Revenue',
                          value: _formatCurrency(state.stats!.totalRevenue),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.tertiary,
                          trendValue: '+21%',
                        ),
                        StatSummaryCard(
                          title: 'Baru Bulan Ini',
                          value: '+${state.stats!.newTenantsThisMonth}',
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF6366F1),
                          trendValue: 'Naik!',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // ── Recent Activity ────────────────────────────────
                    Text(
                      'Aktivitas Terbaru',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBase,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.surfaceStrong),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            context,
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.secondary,
                            bgColor: AppColors.secondary.withOpacity(0.1),
                            title: 'Bakso Pak Slamet membayar langganan',
                            time: '2 men lalu',
                            isLast: false,
                          ),
                          _buildActivityItem(
                            context,
                            icon: Icons.storefront_outlined,
                            iconColor: AppColors.primary,
                            bgColor: AppColors.primary.withOpacity(0.1),
                            title: 'Tenant baru: Ayam Geprek Mercon',
                            time: '1 jam lalu',
                            isLast: false,
                          ),
                          _buildActivityItem(
                            context,
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.tertiary,
                            bgColor: AppColors.tertiary.withOpacity(0.1),
                            title: 'Soto Betawi Bang Haji – langganan hampir habis',
                            time: '3 jam lalu',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String time,
    required bool isLast,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space2),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: AppSpacing.space4,
            endIndent: AppSpacing.space4,
            color: AppColors.surfaceStrong,
          ),
      ],
    );
  }
}
