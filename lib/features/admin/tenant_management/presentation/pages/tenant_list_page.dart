import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
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
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNeutral,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tenant Management',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${visibleTenants.length} merchant terdaftar',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space4),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Tenant — Coming Soon')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
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
        child: Column(
          children: [
            // ── Search + Filters ──────────────────────────────────
            Container(
              color: AppColors.surfaceNeutral,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space4,
                AppSpacing.space2,
                AppSpacing.space4,
                AppSpacing.space3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Cari merchant atau pemilik...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _controller.updateSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.surfaceStrong),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.surfaceStrong),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceBase,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space3,
                        horizontal: AppSpacing.space4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          value: 'all',
                          selected: state.filterStatus,
                          onSelected: _controller.updateFilter,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        _FilterChip(
                          label: 'Aktif',
                          value: 'active',
                          selected: state.filterStatus,
                          onSelected: _controller.updateFilter,
                          activeColor: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        _FilterChip(
                          label: 'Nonaktif',
                          value: 'inactive',
                          selected: state.filterStatus,
                          onSelected: _controller.updateFilter,
                          activeColor: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : visibleTenants.isEmpty
                      ? _EmptyState(
                          query: state.searchQuery,
                          onClear: () {
                            _searchController.clear();
                            _controller.updateSearch('');
                            _controller.updateFilter('all');
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.space4,
                            AppSpacing.space2,
                            AppSpacing.space4,
                            AppSpacing.space12,
                          ),
                          itemCount: visibleTenants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.space3),
                          itemBuilder: (context, index) =>
                              TenantCard(tenant: visibleTenants[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
    this.activeColor = AppColors.primary,
  });

  final String label;
  final String value;
  final String selected;
  final void Function(String) onSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.surfaceStrong,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.surfaceStrong,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              query.isEmpty
                  ? 'Belum ada tenant terdaftar'
                  : 'Tidak ada tenant ditemukan',
              style: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                'Coba ubah kata kunci atau filter',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space5),
              TextButton(
                onPressed: onClear,
                child: const Text(
                  'Reset Pencarian',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
