import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/repositories/tenant_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/controllers/tenant_list_controller.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/widgets/tenant_card.dart';
import 'package:flutter/material.dart';

class TenantListPage extends StatefulWidget {
  const TenantListPage({super.key});

  @override
  State<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends State<TenantListPage> {
  late final TenantListController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repository = TenantRepositoryImpl(TenantLocalDataSource());
    _controller = TenantListController(repository)
      ..addListener(_onControllerUpdated)
      ..initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    final visibleTenants = _controller.visibleTenants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Tenant - Coming Soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Cari nama merchant atau pemilik...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceStrong),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceStrong),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceSoft,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', 'all', state.filterStatus),
                        const SizedBox(width: AppSpacing.space2),
                        _buildFilterChip('Aktif', 'active', state.filterStatus),
                        const SizedBox(width: AppSpacing.space2),
                        _buildFilterChip('Nonaktif', 'inactive', state.filterStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : visibleTenants.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada tenant ditemukan.',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                          itemCount: visibleTenants.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.space3),
                          itemBuilder: (context, index) {
                            return TenantCard(tenant: visibleTenants[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _controller.updateFilter(value),
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceStrong,
        ),
      ),
    );
  }
}
