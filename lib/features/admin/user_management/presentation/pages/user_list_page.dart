import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/repositories/user_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/presentation/controllers/user_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── User list page ────────────────────────────────────────────────────────────
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late final UserListController _controller;
  final TextEditingController _searchCtrl = TextEditingController();

  static const _filterTabs = [
    ('all', 'All Users'),
    ('admin', 'Admin'),
    ('merchant', 'Merchant'),
    ('staff', 'Staff'),
  ];

  @override
  void initState() {
    super.initState();
    final repo = UserRepositoryImpl(
      UserLocalDataSource(),
      UserRemoteDataSource(ApiClient()),
    );
    _controller = UserListController(repo)
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
    final visible = _controller.visibleUsers;
    final all = state.users;
    final tt = Theme.of(context).textTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: state.isLoading && all.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : CustomScrollView(
                    slivers: [
                      // ── Metrics ───────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: _buildTopMetrics(tt, all),
                      ),

                      // ── Page header ───────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.space4,
                              AppSpacing.space5,
                              AppSpacing.space4,
                              AppSpacing.space3),
                          child: _buildPageHeader(tt),
                        ),
                      ),

                      // ── Filter tabs ───────────────────────────────────────
                      SliverToBoxAdapter(
                        child: _buildFilterTabs(tt, state),
                      ),

                      // ── User list ─────────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.space4,
                            AppSpacing.space3,
                            AppSpacing.space4,
                            AppSpacing.space16),
                        sliver: _buildUserList(tt, visible),
                      ),
                    ],
                  ),
          ),
        ),
        if (state.isLoading && all.isNotEmpty)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(width: 16),
                      Text('Memproses data...', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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
            hintText: 'Search user, email, or tenant...',
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
            icon: const Icon(Icons.manage_accounts_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Roles Settings',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Roles settings — Coming Soon')),
            ),
          ),
        ),
      ],
    );
  }

  // ── Top metrics ────────────────────────────────────────────────────────────
  Widget _buildTopMetrics(TextTheme tt, List<UserEntity> users) {
    final active = users.where((u) => u.status == 'active').length;
    final suspended = users.where((u) => u.status == 'suspended').length;
    final admins = users.where((u) => u.role == 'admin').length;

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 520;

      final cells = [
        _MetricCell(
          label: 'TOTAL ACTIVE USERS',
          value: '$active',
          sub: 'Across all tenants & platform',
          subIcon: Icons.people_outline_rounded,
          subColor: AppColors.secondary,
        ),
        _MetricCell(
          label: 'SUSPENDED ACCOUNTS',
          value: '$suspended',
          sub: 'Requires review',
          subIcon: Icons.gpp_maybe_outlined,
          subColor: AppColors.statusError,
        ),
        _MetricCell(
          label: 'ADMINISTRATORS',
          value: '$admins',
          sub: 'Platform super users',
          subIcon: Icons.admin_panel_settings_outlined,
          subColor: AppColors.textSecondary,
        ),
      ];

      return Container(
        color: AppColors.surfaceBase,
        padding: EdgeInsets.symmetric(
            vertical: AppSpacing.space5,
            horizontal: narrow ? AppSpacing.space4 : 0),
        child: narrow
            ? Column(
                children: cells
                    .expand<Widget>((c) => [c, const SizedBox(height: AppSpacing.space4)])
                    .toList()
                  ..removeLast(),
              )
            : IntrinsicHeight(
                child: Row(children: [
                  cells[0],
                  const _VDivider(),
                  cells[1],
                  const _VDivider(),
                  cells[2],
                ]),
              ),
      );
    });
  }

  // ── Page header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 560;

      final titleCol = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Management',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text('Manage access, roles, and status of platform users.',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      );

      final addBtn = DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFAB3500), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ElevatedButton.icon(
          onPressed: _showInviteDialog,
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Invite User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
          ),
        ),
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleCol,
            const SizedBox(height: AppSpacing.space3),
            addBtn,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleCol),
          addBtn,
        ],
      );
    });
  }

  // ── Filter tabs ────────────────────────────────────────────────────────────
  Widget _buildFilterTabs(TextTheme tt, state) {
    final currentFilter = _controller.state.filterRole;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Row(
        children: _filterTabs.map((tab) {
          final (key, label) = tab;
          final isActive = currentFilter == key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: GestureDetector(
              onTap: () => _controller.updateFilter(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surfaceStrong,
                  ),
                ),
                child: Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color:
                        isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── User list ────────────────────────────────────────────────────────────
  Widget _buildUserList(TextTheme tt, List<UserEntity> items) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_outlined,
                  size: 48, color: AppColors.surfaceStrong),
              const SizedBox(height: AppSpacing.space3),
              Text('Tidak ada pengguna ditemukan.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space3),
          child: _UserCard(
            user: items[index],
            onEdit: () => _showEditDialog(items[index]),
            onToggle: () => _showToggleConfirm(items[index]),
            onDelete: () => _showDeleteConfirm(items[index]),
          ),
        ),
        childCount: items.length,
      ),
    );
  }

  // ── Dialogs & Interactions ────────────────────────────────────────────────
  void _showInviteDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'staff';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Invite / Daftarkan Pengguna Baru', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daftarkan user baru ke sistem dan tentukan rolenya.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email harus diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Password (min. 6 karakter)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (v) => (v == null || v.trim().length < 6) ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Role Pengguna:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin (Platform)')),
                      DropdownMenuItem(value: 'merchant', child: Text('Merchant (Partner Tenant)')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff (Tenant Cashier/Ops)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedRole = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  try {
                    await _controller.createUser(
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passwordCtrl.text,
                      role: selectedRole,
                    );
                    _showSnackbar('Pengguna berhasil didaftarkan!', isError: false);
                  } catch (e) {
                    _showSnackbar('Gagal mendaftarkan pengguna: $e', isError: true);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Daftarkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(UserEntity user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Edit Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah data profil pengguna terpilih.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email harus diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Ubah Role Pengguna:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin (Platform)')),
                      DropdownMenuItem(value: 'merchant', child: Text('Merchant (Partner Tenant)')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff (Tenant Cashier/Ops)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedRole = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  try {
                    await _controller.updateUser(
                      id: user.id,
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      role: selectedRole,
                    );
                    _showSnackbar('Profil pengguna berhasil diubah!', isError: false);
                  } catch (e) {
                    _showSnackbar('Gagal mengubah profil: $e', isError: true);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showToggleConfirm(UserEntity user) {
    final isActive = user.status == 'active';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text(isActive ? 'Nonaktifkan Pengguna?' : 'Aktifkan Pengguna?'),
        content: Text(
          'Apakah Anda yakin ingin ${isActive ? 'menonaktifkan' : 'mengaktifkan'} akses untuk pengguna ${user.name}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _controller.toggleActive(user.id);
                _showSnackbar('Status pengguna berhasil diubah!', isError: false);
              } catch (e) {
                _showSnackbar('Gagal mengubah status pengguna: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.statusError : AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.statusError),
            SizedBox(width: 8),
            Text('Hapus Pengguna?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna ${user.name}? Tindakan ini bersifat permanen dan tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _controller.deleteUser(user.id);
                _showSnackbar('Pengguna berhasil dihapus!', isError: false);
              } catch (e) {
                _showSnackbar('Gagal menghapus pengguna: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.statusError : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─── Metric cell ──────────────────────────────────────────────────────────────
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
                style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
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

// ─── Vertical divider ──────────────────────────────────────────────────────────
class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 60, color: AppColors.surfaceStrong);
}

// ─── User card ──────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final UserEntity user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  Color get _statusColor {
    switch (user.status) {
      case 'active':
        return AppColors.secondary;
      case 'inactive':
        return AppColors.textSecondary;
      case 'suspended':
        return AppColors.statusError;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _roleAccent {
    switch (user.role) {
      case 'admin':
        return AppColors.primary;
      case 'merchant':
        return AppColors.secondary;
      case 'staff':
        return const Color(0xFF3B82F6); // Blue
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final badgeStatus = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: _statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              user.status.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                  color: _statusColor, fontWeight: FontWeight.w700),
            ),
          ]),
        );

        final badgeRole = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _roleAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: tt.labelSmall?.copyWith(
                color: _roleAccent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
          ),
        );

        final avatar = Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceStrong),
          ),
          child: Text(
            user.avatarInitials ?? 'U',
            style: tt.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800),
          ),
        );

        final optionMenu = PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
          onSelected: (action) {
            if (action == 'edit') {
              onEdit();
            } else if (action == 'toggle') {
              onToggle();
            } else if (action == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Text('Edit Profil'),
              ]),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(children: [
                Icon(
                  user.status == 'active' ? Icons.block_outlined : Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(user.status == 'active' ? 'Nonaktifkan' : 'Aktifkan'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 16, color: AppColors.statusError),
                SizedBox(width: 8),
                Text('Hapus Pengguna', style: TextStyle(color: AppColors.statusError)),
              ]),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  avatar,
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(user.email,
                            style: tt.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  optionMenu,
                ],
              ),
              if (user.tenantName != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Row(children: [
                  Icon(Icons.store_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(user.tenantName!,
                        style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
              const SizedBox(height: AppSpacing.space3),
              Row(
                children: [
                  badgeRole,
                  const Spacer(),
                  badgeStatus,
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Row(
                children: [
                  Icon(Icons.login_rounded, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    user.lastLogin != null
                        ? 'Last login: ${_fmtDate(user.lastLogin!)}'
                        : 'Never logged in',
                    style: tt.labelSmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            avatar,
            const SizedBox(width: AppSpacing.space4),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.name,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: AppSpacing.space2),
                      badgeRole,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(user.email,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  if (user.tenantName != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.store_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(user.tenantName!,
                          style: tt.labelSmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space4),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  badgeStatus,
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.login_rounded,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        user.lastLogin != null
                            ? 'Last init: ${_fmtDate(user.lastLogin!)}'
                            : 'N/A',
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space4),
            optionMenu,
          ],
        );
      }),
    );
  }
}
