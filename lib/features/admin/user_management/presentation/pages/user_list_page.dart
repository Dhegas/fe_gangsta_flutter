import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/datasources/user_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/data/repositories/user_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/presentation/controllers/user_list_controller.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/presentation/pages/user_detail_page.dart';
import 'package:flutter/material.dart';


// ─── User list page ────────────────────────────────────────────────────────────
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late final UserListController _controller;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = UserRepositoryImpl(
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
    final tt = Theme.of(context).textTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: state.isLoading && state.users.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : CustomScrollView(
                    slivers: [
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

                      // ── Filter Bar ────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: _buildFilterBar(tt, state),
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
        if (state.isLoading && state.users.isNotEmpty)
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
            hintText: 'Cari nama atau email pengguna...',
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
    );
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
          onPressed: _showAddUserDialog,
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Add User'),
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

  // ── Filter Bar ───────────────────────────────────────────────────────────
  Widget _buildFilterBar(TextTheme tt, state) {
    final currentFilter = state.filterRole as String;
    final visibleCount = _controller.visibleUsers.length;

    String filterLabel;
    IconData filterIcon;
    switch (currentFilter) {
      case 'PARTNER':
        filterLabel = 'Partner';
        filterIcon = Icons.handshake_outlined;
        break;
      case 'CUSTOMER':
        filterLabel = 'Customer';
        filterIcon = Icons.person_outline_rounded;
        break;
      default:
        filterLabel = 'All Users';
        filterIcon = Icons.people_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: active filter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.surfaceStrong),
            ),
            child: Row(
              children: [
                Icon(filterIcon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '$filterLabel ($visibleCount)',
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Right: Filter burger menu
          PopupMenuButton<String>(
            tooltip: 'Filter Users',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceBase,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceStrong),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF191C1E).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_open_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onSelected: (key) => _controller.updateFilter(key),
            itemBuilder: (context) => [
              _filterMenuItem('ALL', 'All Users', Icons.people_outline_rounded, currentFilter),
              _filterMenuItem('PARTNER', 'Partner', Icons.handshake_outlined, currentFilter),
              _filterMenuItem('CUSTOMER', 'Customer', Icons.person_outline_rounded, currentFilter),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _filterMenuItem(
    String value,
    String label,
    IconData icon,
    String currentFilter,
  ) {
    final isActive = currentFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
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
            onTap: () => _navigateToDetail(items[index]),
          ),
        ),
        childCount: items.length,
      ),
    );
  }

  // ── Dialogs & Interactions ────────────────────────────────────────────────
  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'CUSTOMER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daftarkan user baru ke sistem dan tentukan rolenya.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
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
                    validator: (v) =>
                        (v == null || v.trim().length < 6) ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Role:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'CUSTOMER', child: Text('Customer')),
                      DropdownMenuItem(value: 'PARTNER', child: Text('Partner')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedRole = val);
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
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Daftarkan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(UserEntity initialUser) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      final detailedUser = await _controller.getUserDetail(initialUser.id);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailPage(user: detailedUser),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        _showSnackbar('Gagal mengambil detail user: $e', isError: true);
      }
    }
  }

  void _showEditDialog(UserEntity user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    String selectedRole = (user.role == 'PARTNER') ? 'PARTNER' : 'CUSTOMER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Edit Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah data profil pengguna terpilih.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
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
                  const Text('Role:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'CUSTOMER', child: Text('Customer')),
                      DropdownMenuItem(value: 'PARTNER', child: Text('Partner')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedRole = val);
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
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showToggleConfirm(UserEntity user) {
    final isActive = user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text(isActive ? 'Nonaktifkan Pengguna?' : 'Aktifkan Pengguna?'),
        content: Text(
          'Apakah Anda yakin ingin ${isActive ? 'menonaktifkan' : 'mengaktifkan'} akses untuk ${user.name}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
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
              backgroundColor:
                  isActive ? AppColors.statusError : AppColors.secondary,
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
          'Apakah Anda yakin ingin menghapus ${user.name}? Tindakan ini bersifat permanen.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
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


// ─── User card ──────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  final UserEntity user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  Color get _statusColor {
    return user.isActive ? AppColors.secondary : AppColors.textSecondary;
  }

  Color get _roleAccent {
    switch (user.role) {
      case 'ADMIN':
        return AppColors.primary;
      case 'PARTNER':
        return AppColors.secondary;
      case 'CUSTOMER':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1E).withValues(alpha: 0.06),
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
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                user.isActive ? 'ACTIVE' : 'INACTIVE',
                style: tt.labelSmall
                    ?.copyWith(color: _statusColor, fontWeight: FontWeight.w700),
              ),
            ]),
          );

          final badgeRole = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _roleAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              user.role,
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
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800),
            ),
          );

          final optionMenu = PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (action) {
              if (action == 'detail') {
                onTap();
              } else if (action == 'edit') {
                onEdit();
              } else if (action == 'toggle') {
                onToggle();
              } else if (action == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'detail',
                child: Row(children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ]),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text('Edit Pengguna'),
                ]),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    user.isActive ? Icons.block_outlined : Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 16, color: AppColors.statusError),
                  SizedBox(width: 8),
                  Text('Hapus Pengguna',
                      style: TextStyle(color: AppColors.statusError)),
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
                const SizedBox(height: AppSpacing.space3),
                Row(
                  children: [
                    badgeRole,
                    const Spacer(),
                    badgeStatus,
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
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              badgeStatus,
              const SizedBox(width: AppSpacing.space4),
              optionMenu,
            ],
          );
        }),
      ),
    );
  }
}
