import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_create_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/controllers/tenant_create_controller.dart';
import 'package:flutter/material.dart';

class TenantCreatePage extends StatefulWidget {
  const TenantCreatePage({super.key, required this.repository});

  final TenantRepository repository;

  @override
  State<TenantCreatePage> createState() => _TenantCreatePageState();
}

class _TenantCreatePageState extends State<TenantCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late final TenantCreateController _controller;

  final _userIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _openHoursCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();

  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _controller = TenantCreateController(widget.repository)
      ..addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    _userIdCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _openHoursCtrl.dispose();
    _logoCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool _isValidUuid(String value) {
    final trimmed = value.trim();
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-'
      r'[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(trimmed);
  }

  bool _isValidUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    final uri = Uri.tryParse(trimmed);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  InputDecoration _inputDecoration(
    TextTheme tt,
    String label,
    String hint, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
      hintStyle: tt.bodySmall?.copyWith(color: AppColors.textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
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
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: 12,
      ),
    );
  }

  Widget _buildSectionCard(
    TextTheme tt,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            subtitle,
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextTheme tt,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(tt, label, hint, icon: icon),
      validator: validator,
    );
  }

  Widget _buildStatusField(TextTheme tt) {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: _inputDecoration(
        tt,
        'Status Tenant',
        'Pilih status tenant',
        icon: Icons.flag_outlined,
      ),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('active')),
        DropdownMenuItem(value: 'inactive', child: Text('inactive')),
        DropdownMenuItem(value: 'suspended', child: Text('suspended')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _status = value;
        });
      },
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = TenantCreateEntity(
      userId: _userIdCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      status: _status,
      description: _optionalValue(_descCtrl.text),
      address: _optionalValue(_addressCtrl.text),
      phoneNumber: _optionalValue(_phoneCtrl.text),
      openHours: _optionalValue(_openHoursCtrl.text),
      logoUrl: _optionalValue(_logoCtrl.text),
      bannerUrl: _optionalValue(_bannerCtrl.text),
    );

    try {
      await _controller.submit(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tenant berhasil ditambahkan!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan tenant: $e'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final state = _controller.state;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        title: const Text('Tambah Tenant Baru'),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AbsorbPointer(
            absorbing: state.isSubmitting,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      decoration: BoxDecoration(
                        color: AppColors.statusError.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.statusError.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.statusError,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                  ],
                  _buildSectionCard(
                    tt,
                    'Identitas Tenant',
                    'Lengkapi informasi utama tenant dan pemiliknya.',
                    [
                      _buildTextField(
                        tt: tt,
                        controller: _userIdCtrl,
                        label: 'User ID (Owner) *',
                        hint: 'UUID pemilik tenant',
                        icon: Icons.person_outline,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return 'User ID wajib diisi';
                          if (!_isValidUuid(trimmed))
                            return 'Format UUID tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      _buildTextField(
                        tt: tt,
                        controller: _nameCtrl,
                        label: 'Nama Tenant *',
                        hint: 'e.g. Bakso Gangsta',
                        icon: Icons.storefront_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tenant wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      _buildStatusField(tt),
                      const SizedBox(height: AppSpacing.space3),
                      _buildTextField(
                        tt: tt,
                        controller: _descCtrl,
                        label: 'Deskripsi',
                        hint: 'Deskripsi singkat tenant',
                        icon: Icons.notes_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _buildSectionCard(
                    tt,
                    'Kontak & Operasional',
                    'Alamat, kontak, dan jam operasional tenant.',
                    [
                      _buildTextField(
                        tt: tt,
                        controller: _addressCtrl,
                        label: 'Alamat',
                        hint: 'Alamat tenant',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      _buildTextField(
                        tt: tt,
                        controller: _phoneCtrl,
                        label: 'Nomor Telepon',
                        hint: 'e.g. 081234567890',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      _buildTextField(
                        tt: tt,
                        controller: _openHoursCtrl,
                        label: 'Jam Operasional',
                        hint: 'e.g. 08:00 - 21:00',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _buildSectionCard(
                    tt,
                    'Branding Tenant',
                    'Tambahkan URL logo dan banner tenant (opsional).',
                    [
                      _buildTextField(
                        tt: tt,
                        controller: _logoCtrl,
                        label: 'Logo URL',
                        hint: 'https://...',
                        icon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          final v = value ?? '';
                          if (!_isValidUrl(v)) return 'URL logo tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      _buildTextField(
                        tt: tt,
                        controller: _bannerCtrl,
                        label: 'Banner URL',
                        hint: 'https://...',
                        icon: Icons.wallpaper_outlined,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          final v = value ?? '';
                          if (!_isValidUrl(v)) return 'URL banner tidak valid';
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.surfaceStrong,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Simpan Tenant'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
