import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/repositories/tenant_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/pages/tenant_create_page.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/controllers/tenant_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─── Static data ──────────────────────────────────────────────────────────────
const _kTierGradients = {
  'enterprise': [Color(0xFFFF6B35), Color(0xFFAB3500)],
  'pro': [Color(0xFF2ECC71), Color(0xFF1A9A50)],
  'basic': [Color(0xFF64748B), Color(0xFF475569)],
};

// ─── Page ──────────────────────────────────────────────────────────────────────
class TenantListPage extends StatefulWidget {
  const TenantListPage({super.key});

  @override
  State<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends State<TenantListPage> {
  late final TenantListController _controller;
  late final TenantRepository _repository;
  final TextEditingController _searchCtrl = TextEditingController();
  final http.Client _httpClient = http.Client();

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      client: _httpClient,
      getAccessToken: () => ApiConfig.token,
    );
    final remoteDataSource = TenantRemoteDataSource(apiClient);
    final repo = TenantRepositoryImpl(remoteDataSource);
    _repository = repo;
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
    _httpClient.close();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _openCreateTenantPage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TenantCreatePage(repository: _repository),
      ),
    );

    if (!mounted) return;
    if (created == true) {
      await _controller.loadPage(1);
    }
  }

  Future<void> _showDeleteConfirmDialog(String id, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        final tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: AppColors.surfaceBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text(
            'Hapus Tenant',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.statusError,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus tenant "$name"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusError,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(ctx).pop();

                // Show loading SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Menghapus tenant...'),
                      ],
                    ),
                    duration: Duration(days: 1),
                  ),
                );

                try {
                  await _controller.deleteTenant(id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tenant berhasil dihapus!'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus tenant: ${e.toString()}'),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                slivers: [
                  // ── 3 top metrics ─────────────────────────────────────────
                  SliverToBoxAdapter(child: _buildTopMetrics(tt, all)),

                  // ── Directory header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space3,
                      ),
                      child: _buildDirectoryHeader(tt),
                    ),
                  ),

                  // ── Grid of cards ─────────────────────────────────────────
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada tenant ditemukan.',
                          style: tt.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space4,
                        0,
                        AppSpacing.space4,
                        0,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _TenantCard(
                            tenant: visible[i],
                            onDelete: (id) =>
                                _showDeleteConfirmDialog(id, visible[i].name),
                          ),
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
                  SliverToBoxAdapter(child: _buildPagination(tt)),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.space12),
                  ),
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
            hintText: 'Search tenants, tiers, or status...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 18,
            ),
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
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ── Top 3 metrics ──────────────────────────────────────────────────────────
  Widget _buildTopMetrics(TextTheme tt, List<TenantEntity> tenants) {
    final activeCount = tenants.where((t) => t.status == 'active').length;
    final inactiveCount = tenants.where((t) => t.status != 'active').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 500;
        final cells = [
          _MetricCell(
            label: 'TOTAL TENANTS',
            value: '${tenants.length}',
            sub: 'All registered tenants',
            subIcon: Icons.storefront_rounded,
            subColor: AppColors.primary,
          ),
          _MetricCell(
            label: 'ACTIVE TENANTS',
            value: '$activeCount',
            sub: 'Currently active & operational',
            subIcon: Icons.check_circle_outline_rounded,
            subColor: AppColors.secondary,
          ),
          _MetricCell(
            label: 'INACTIVE TENANTS',
            value: '$inactiveCount',
            sub: 'Suspended or non-active',
            subIcon: Icons.cancel_outlined,
            subColor: AppColors.statusError,
          ),
        ];

        return Container(
          color: AppColors.surfaceBase,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.space5,
            horizontal: narrow ? AppSpacing.space4 : 0,
          ),
          child: narrow
              ? Column(
                  children:
                      cells
                          .expand(
                            (c) => [
                              c,
                              const SizedBox(height: AppSpacing.space4),
                            ],
                          )
                          .toList()
                        ..removeLast(),
                )
              : IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(child: cells[0]),
                      const _Vdivider(),
                      Expanded(child: cells[1]),
                      const _Vdivider(),
                      Expanded(child: cells[2]),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ── Directory header ───────────────────────────────────────────────────────
  Widget _buildDirectoryHeader(TextTheme tt) {
    return LayoutBuilder(
      builder: (context, con) {
        final narrow = con.maxWidth < 440;
        final addBtn = DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAB3500), Color(0xFFFF6B35)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ElevatedButton.icon(
            onPressed: _openCreateTenantPage,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Tenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
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
        );

        final filterBtn = OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded, size: 16),
          label: const Text('Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.surfaceStrong),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        );

        return narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenants Directory',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Row(
                    children: [
                      Expanded(child: filterBtn),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(child: addBtn),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    'Tenants Directory',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  filterBtn,
                  const SizedBox(width: AppSpacing.space2),
                  addBtn,
                ],
              );
      },
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────────────
  Widget _buildPagination(TextTheme tt) {
    final page = _controller.state.page;
    final limit = _controller.state.limit;
    final totalItems = _controller.state.totalItems;
    final totalPages = _controller.state.totalPages;

    final startItem = totalItems == 0 ? 0 : (page - 1) * limit + 1;
    final endItem = (page * limit) > totalItems ? totalItems : (page * limit);

    List<Widget> pageButtons = [];

    // Previous button
    pageButtons.add(
      _PageBtn(
        label: '‹',
        enabled: page > 1,
        onTap: () => _controller.loadPage(page - 1),
      ),
    );
    pageButtons.add(const SizedBox(width: AppSpacing.space2));

    // Page numbers
    for (int i = 1; i <= totalPages; i++) {
      pageButtons.add(
        _PageBtn(
          label: '$i',
          active: i == page,
          onTap: () => _controller.loadPage(i),
        ),
      );
      pageButtons.add(const SizedBox(width: AppSpacing.space2));
    }

    // Next button
    pageButtons.add(
      _PageBtn(
        label: '›',
        enabled: page < totalPages,
        onTap: () => _controller.loadPage(page + 1),
      ),
    );

    return Container(
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Showing $startItem–$endItem of $totalItems tenants',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          ...pageButtons,
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            value,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              Icon(subIcon, size: 14, color: subColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  sub,
                  style: tt.labelSmall?.copyWith(color: subColor),
                ),
              ),
            ],
          ),
        ],
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
// ─── Tenant card ─────────────────────────────────────────────────────────────
class _TenantCard extends StatelessWidget {
  const _TenantCard({required this.tenant, this.onDelete});

  final TenantEntity tenant;
  final Function(String id)? onDelete;

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
    final name = tenant.name.trim();
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    if (name.isNotEmpty) return name.toUpperCase();
    return 'OS';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final desc = tenant.description.isNotEmpty
        ? tenant.description
        : 'Tenant kuliner terdaftar pada platform CulinaryOS. Melayani pelanggan setiap hari dengan menu pilihan terbaik.';

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
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                // Tier badge – top left
                Positioned(
                  top: AppSpacing.space3,
                  left: AppSpacing.space3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      tenant.subscriptionPlan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 100),
                      onSelected: (val) {
                        if (val == 'delete' && onDelete != null) {
                          onDelete!(tenant.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.statusError,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: AppColors.statusError,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar + status – bottom left
                Positioned(
                  bottom: AppSpacing.space3,
                  left: AppSpacing.space4,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: tenant.logoUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(tenant.logoUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: tenant.logoUrl.isEmpty
                            ? Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withValues(alpha: 0.455),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tenant.status == 'active' ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  tenant.name,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space1),
                // Partner
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        tenant.partnerName,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                // Description
                Text(
                  desc,
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space3),
                // Bottom: ID + tier badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ID: ${tenant.id}',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _tierColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        tenant.subscriptionPlan.toUpperCase(),
                        style: tt.labelSmall?.copyWith(
                          color: _tierColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination button ─────────────────────────────────────────────────────────
class _PageBtn extends StatelessWidget {
  const _PageBtn({
    required this.label,
    this.active = false,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool active, enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: active
                ? Colors.white
                : enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
