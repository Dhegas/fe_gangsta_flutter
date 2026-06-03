import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_local_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_remote_datasource_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/repositories/table_management_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/controllers/table_management_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:flutter/material.dart';

class TableStatusPage extends StatefulWidget {
  const TableStatusPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<TableStatusPage> createState() => _TableStatusPageState();
}

class _TableStatusPageState extends State<TableStatusPage> {
  late final TableManagementController _controller;
  final MerchantNavItem _selectedNav = MerchantNavItem.tables;

  @override
  void initState() {
    super.initState();
    final repository = TableManagementRepositoryImpl(
      remoteDataSource: TableManagementRemoteDataSourceImpl(),
      localDataSource: TableManagementLocalDataSourceImpl(),
    );
    _controller = TableManagementController(repository)
      ..addListener(_onControllerChanged)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1120;
        final isTablet = constraints.maxWidth >= 760;

        return Scaffold(
          bottomNavigationBar: isDesktop
              ? null
              : MerchantBottomNav(
                  selectedItem: _selectedNav,
                  onTapItem: _handleNavTap,
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  MerchantSidebar(
                    merchantName: ApiClient.activeTenantName ?? 'Toko',
                    merchantRoleLabel: 'Partner Lead',
                    selectedItem: _selectedNav,
                    onTapItem: _handleNavTap,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MerchantTopBar(
                          onSearchChanged: (_) {},
                          isCompact: !isTablet,
                          showSearchBar: false,
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.space4),
                        Expanded(
                          child: state.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildTablesGrid(isDesktop, isTablet),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Meja',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola nomor meja yang dapat digunakan di outlet Anda',
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => _controller.initialize(),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Daftar Meja',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTablesGrid(bool isDesktop, bool isTablet) {
    final state = _controller.state;
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.tables.length + 1,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.space3,
        crossAxisSpacing: AppSpacing.space3,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddTableCard(isDarkMode);
        }

        final table = state.tables[index - 1];
        return _buildTableCard(table, isDarkMode);
      },
    );
  }

  Widget _buildAddTableCard(bool isDarkMode) {
    return InkWell(
      onTap: _showAddTableDialog,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF334155) : Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah Meja',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(TableEntity table, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.table_restaurant_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showEditTableDialog(table),
                    tooltip: 'Ubah Nama Meja',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    onPressed: () => _showDeleteTableDialog(table),
                    tooltip: 'Hapus Meja',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            table.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Nomor Meja',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _handleNavTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }
    navigateToMerchantSection(context, item, MerchantNavItem.tables);
  }

  void _showAddTableDialog() {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Meja Baru'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Meja 01, VIP 03',
              labelText: 'Nama / Nomor Meja',
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama meja tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final name = textController.text.trim();
                Navigator.of(context).pop();
                final success = await _controller.addTable(name);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Meja "$name" berhasil ditambahkan')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal menambahkan meja')),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(TableEntity table) {
    final textController = TextEditingController(text: table.name);
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Meja'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Nama / Nomor Meja',
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama meja tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final name = textController.text.trim();
                Navigator.of(context).pop();
                final success = await _controller.updateTable(table.id, name);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Meja berhasil diubah menjadi "$name"')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mengubah nama meja')),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTableDialog(TableEntity table) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Meja'),
        content: Text('Apakah Anda yakin ingin menghapus meja "${table.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _controller.deleteTable(table.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meja "${table.name}" berhasil dihapus')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus meja')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
