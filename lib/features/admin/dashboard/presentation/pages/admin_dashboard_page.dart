import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.space2),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceStrong,
            child: Icon(Icons.person, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.space4),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || state.stats == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Platform',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: AppSpacing.space4,
                        crossAxisSpacing: AppSpacing.space4,
                        mainAxisExtent: 200, 
                      ),
                      children: [
                        StatSummaryCard(
                          title: 'Total Tenant',
                          value: '${state.stats!.totalTenants}',
                          icon: Icons.storefront,
                          color: AppColors.primary,
                          trendValue: '+12% bln ini',
                        ),
                        StatSummaryCard(
                          title: 'Active Subscription',
                          value: '${state.stats!.activeMemberships}',
                          icon: Icons.workspace_premium,
                          color: AppColors.secondary,
                          trendValue: '+5% bln ini',
                        ),
                        StatSummaryCard(
                          title: 'Total Revenue',
                          value: _formatCurrency(state.stats!.totalRevenue),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.tertiary,
                          trendValue: '+21% dr bln lalu',
                        ),
                        StatSummaryCard(
                          title: 'New This Month',
                          value: '+${state.stats!.newTenantsThisMonth}',
                          icon: Icons.fiber_new_rounded,
                          color: Colors.blue,
                          trendValue: 'Terus Naik!',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Activities', style: textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.space3),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: AppColors.secondary, size: 20),
                            ),
                            title: const Text('Bakso Pak Slamet paid subscription'),
                            subtitle: const Text('2 mins ago'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                            ),
                            title: const Text('New tenant registered: Ayam Geprek Mercon'),
                            subtitle: const Text('1 hour ago'),
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
}
