import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Kelola Membership'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tambah Paket - Coming Soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Paket Berlangganan SaaS',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Kelola daftar paket dan harga yang ditawarkan kepada tenant merchant.',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    if (state.memberships.isEmpty)
                      Center(
                        child: Text(
                          'Tidak ada paket membership.',
                          style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...state.memberships.map((membership) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                          child: MembershipCard(membership: membership),
                        );
                      }).toList(),
                    const SizedBox(height: AppSpacing.space6),
                  ],
                ),
              ),
      ),
    );
  }
}
