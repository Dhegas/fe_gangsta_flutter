import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/datasources/tenant_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/data/models/tenant_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/merchant_landing_page.dart';
import 'package:flutter/material.dart';

class MerchantTenantSelectionPage extends StatefulWidget {
  const MerchantTenantSelectionPage({super.key});

  @override
  State<MerchantTenantSelectionPage> createState() => _MerchantTenantSelectionPageState();
}

class _MerchantTenantSelectionPageState extends State<MerchantTenantSelectionPage> {
  late final TenantRemoteDataSource _remoteDataSource;
  late final TenantLocalDataSource _localDataSource;
  
  List<TenantModel> _tenants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _localDataSource = TenantLocalDataSource();
    _remoteDataSource = TenantRemoteDataSource(ApiClient());
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<TenantModel> loadedList = [];
      if (ApiConfig.useMockData) {
        // Load simulated partner tenants
        final entities = await _localDataSource.getTenants();
        loadedList = entities.map((e) => TenantModel(
          id: e.id,
          name: e.name,
          ownerName: e.ownerName,
          status: e.status,
          subscriptionPlan: e.subscriptionPlan,
          joinDate: e.joinDate,
        )).toList();
      } else {
        // Fetch real tenants from live Go backend
        loadedList = await _remoteDataSource.getTenants();
      }

      setState(() {
        _tenants = loadedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar toko: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (ApiConfig.useMockData) {
        // Create in mock cache
        final newMock = TenantModel(
          id: 't-mock-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          ownerName: 'Merchant Owner',
          status: 'active',
          subscriptionPlan: 'Pro',
          joinDate: DateTime.now(),
        );
        _tenants.insert(0, newMock);
      } else {
        // Call remote API POST /partner/tenants
        await _remoteDataSource.createTenant(
          name: name,
          description: description,
          address: address,
          phoneNumber: phoneNumber,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toko/Outlet berhasil ditambahkan!'),
          backgroundColor: AppColors.statusSuccess,
        ),
      );

      // Refresh list
      await _loadTenants();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat toko: ${e.toString()}'),
          backgroundColor: AppColors.statusError,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTenant(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (ApiConfig.useMockData) {
        _tenants.removeWhere((t) => t.id == id);
      } else {
        await _remoteDataSource.deleteTenant(id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toko/Outlet berhasil dihapus!'),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
      await _loadTenants();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus toko: ${e.toString()}'),
          backgroundColor: AppColors.statusError,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteTenant(TenantModel tenant) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: AppColors.surfaceBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text(
            'Konfirmasi Hapus',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.statusError),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus outlet "${tenant.name}"? Aksi ini tidak dapat dibatalkan.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusError,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteTenant(tenant.id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _selectTenant(TenantModel tenant) {
    // Set dynamic tenant ID
    ApiClient.activeTenantId = tenant.id;
    ApiClient.activeTenantName = tenant.name;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Masuk ke ${tenant.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Route to Merchant operational landing page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const MerchantLandingPage(),
      ),
    );
  }

  Future<void> _showCreateTenantDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        final tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: AppColors.surfaceBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text(
            'Buat Outlet / Tenant Baru',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Toko *',
                      hintText: 'e.g. Warung Kopi Gangsta',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama toko wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Toko',
                      hintText: 'e.g. Kopi nikmat rasa premium',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Toko',
                      hintText: 'e.g. Jalan Sudirman No. 12',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'e.g. 08123456789',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(ctx).pop();
                  _createTenant(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                  );
                }
              },
              child: const Text('Buat Toko'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        title: const Text('Pilih Toko / Outlet'),
        backgroundColor: AppColors.surfaceBase,
        actions: [
          IconButton(
            onPressed: _loadTenants,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.08),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang!',
                    style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Pilih salah satu toko kuliner Anda untuk mulai mengelola POS, menu, dan meja.',
                    style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.statusError, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage ?? '',
                              textAlign: TextAlign.center,
                              style: tt.bodyMedium?.copyWith(color: AppColors.statusError),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTenants,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_tenants.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceBase,
                                border: Border.all(color: AppColors.surfaceStrong),
                              ),
                              child: Icon(Icons.storefront_outlined, size: 64, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Text(
                              'Anda belum memiliki toko',
                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Buat outlet kuliner pertama Anda untuk mulai berbisnis!',
                              textAlign: TextAlign.center,
                              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.space6),
                            ElevatedButton.icon(
                              onPressed: _showCreateTenantDialog,
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              label: const Text('Buat Outlet Baru'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _tenants.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _tenants.length) {
                            // "Tambah Toko" Card at the end
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                              ),
                              color: AppColors.surfaceBase.withOpacity(0.5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                onTap: _showCreateTenantDialog,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_business_rounded, color: AppColors.primary, size: 36),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tambah Outlet Baru',
                                      style: tt.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final tenant = _tenants[index];
                          final isPro = tenant.subscriptionPlan.toLowerCase() == 'pro';
                          final isEnterprise = tenant.subscriptionPlan.toLowerCase() == 'enterprise';

                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              onTap: () => _selectTenant(tenant),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.space4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tenant.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                        ),
                                        // Tier badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            color: isEnterprise
                                                ? const Color(0xFFFF6B35).withOpacity(0.1)
                                                : (isPro ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                                          ),
                                          child: Text(
                                            tenant.subscriptionPlan.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: isEnterprise
                                                  ? const Color(0xFFFF6B35)
                                                  : (isPro ? const Color(0xFF2ECC71) : Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pemilik: ${tenant.ownerName}',
                                          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Dibuat: ${tenant.joinDate.day}-${tenant.joinDate.month}-${tenant.joinDate.year}',
                                          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => _confirmDeleteTenant(tenant),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.statusError,
                                            size: 20,
                                          ),
                                          tooltip: 'Hapus Outlet',
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Masuk ke Toko',
                                          style: tt.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
