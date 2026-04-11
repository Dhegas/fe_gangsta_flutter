import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/data/datasources/membership_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/data/repositories/membership_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/presentation/controllers/membership_list_controller.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/presentation/widgets/membership_card.dart';
import 'package:flutter/material.dart';

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
    final repository = MembershipRepositoryImpl(MembershipLocalDataSource());
    _controller = MembershipListController(repository)
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

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNeutral,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Membership',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Paket berlangganan SaaS merchant',
              style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space4),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambah Paket — Coming Soon')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Paket'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary Banner ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.08),
                            AppColors.primary.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.memberships.length} Paket Tersedia',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Atur paket agar sesuai kebutuhan merchant',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    Text(
                      'Daftar Paket',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // ── Cards ───────────────────────────────────────
                    if (state.memberships.isEmpty)
                      Center(
                        child: Text(
                          'Tidak ada paket membership.',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      ...state.memberships.map((membership) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.space5),
                          child: MembershipCard(membership: membership),
                        );
                      }).toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
