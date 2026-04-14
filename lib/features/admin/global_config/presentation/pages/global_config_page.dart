import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/data/datasources/global_config_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/data/repositories/global_config_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/presentation/controllers/global_config_controller.dart';
import 'package:flutter/material.dart';

class GlobalConfigPage extends StatefulWidget {
  const GlobalConfigPage({super.key});

  @override
  State<GlobalConfigPage> createState() => _GlobalConfigPageState();
}

class _GlobalConfigPageState extends State<GlobalConfigPage> {
  late final GlobalConfigController _controller;

  // Form controllers
  final _platformFeeCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  final _supportPhoneCtrl = TextEditingController();
  final _termsUrlCtrl = TextEditingController();
  final _privacyUrlCtrl = TextEditingController();

  bool _maintenanceMode = false;
  bool _enableRegistrations = false;

  @override
  void initState() {
    super.initState();
    final repo = GlobalConfigRepositoryImpl(GlobalConfigLocalDataSource());
    _controller = GlobalConfigController(repo)
      ..addListener(_rebuild)
      ..initialize().then((_) => _populateForm());
  }

  void _populateForm() {
    final config = _controller.state.config;
    if (config != null) {
      _platformFeeCtrl.text = config.platformFeePercentage.toString();
      _taxCtrl.text = config.taxPercentage.toString();
      _supportEmailCtrl.text = config.supportEmail;
      _supportPhoneCtrl.text = config.supportPhone;
      _termsUrlCtrl.text = config.termsUrl;
      _privacyUrlCtrl.text = config.privacyPolicyUrl;
      _maintenanceMode = config.maintenanceMode;
      _enableRegistrations = config.enableNewRegistrations;
    }
  }

  @override
  void dispose() {
    _platformFeeCtrl.dispose();
    _taxCtrl.dispose();
    _supportEmailCtrl.dispose();
    _supportPhoneCtrl.dispose();
    _termsUrlCtrl.dispose();
    _privacyUrlCtrl.dispose();
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _handleSave() async {
    final success = await _controller.saveConfig(
      GlobalConfigEntity(
        platformFeePercentage: double.tryParse(_platformFeeCtrl.text) ?? 0.0,
        taxPercentage: double.tryParse(_taxCtrl.text) ?? 0.0,
        maintenanceMode: _maintenanceMode,
        enableNewRegistrations: _enableRegistrations,
        supportEmail: _supportEmailCtrl.text,
        supportPhone: _supportPhoneCtrl.text,
        termsUrl: _termsUrlCtrl.text,
        privacyPolicyUrl: _privacyUrlCtrl.text,
      ),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update configuration')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Global Configuration',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space4),
            child: SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: state.isSaving || state.isLoading ? null : _handleSave,
                icon: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(state.isSaving ? 'Saving...' : 'Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage global settings that affect the entire CulinaryOS platform and its tenants.',
                      style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Access & Operational ────────────────────────────────
                    _buildSectionHeader(tt, Icons.admin_panel_settings_outlined, 'Access & Operation'),
                    _buildSectionCard([
                      _buildSwitchRow(
                        tt,
                        'Platform Maintenance Mode',
                        'Temporarily suspends merchant/customer access. Admin access only.',
                        _maintenanceMode,
                        (v) => setState(() => _maintenanceMode = v),
                      ),
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _buildSwitchRow(
                        tt,
                        'Enable New Tenant Registrations',
                        'Allow new merchants to subscribe to the platform.',
                        _enableRegistrations,
                        (v) => setState(() => _enableRegistrations = v),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.space6),

                    // ── Support & Legal ─────────────────────────────────────
                    _buildSectionHeader(tt, Icons.support_agent_outlined, 'Support & Legal Information'),
                    _buildSectionCard([
                      _buildTextFieldRow(tt, 'Support Email', _supportEmailCtrl, 'Enter support email'),
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _buildTextFieldRow(tt, 'Support Phone', _supportPhoneCtrl, 'Enter support phone'),
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _buildTextFieldRow(tt, 'Terms of Service URL', _termsUrlCtrl, 'Enter terms URL'),
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _buildTextFieldRow(tt, 'Privacy Policy URL', _privacyUrlCtrl, 'Enter privacy URL'),
                    ]),
                    const SizedBox(height: AppSpacing.space16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(TextTheme tt, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.space2),
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextFieldRow(TextTheme tt, String label, TextEditingController ctrl, String hint) {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 600;
      final labelWidget = Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600));
      final inputWidget = TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: tt.bodyMedium?.copyWith(color: AppColors.textMuted),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: 12),
        ),
      );

      if (narrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget,
            const SizedBox(height: AppSpacing.space2),
            inputWidget,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: labelWidget),
          Expanded(flex: 3, child: inputWidget),
        ],
      );
    });
  }

  Widget _buildSwitchRow(TextTheme tt, String title, String desc, bool value, ValueChanged<bool> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(desc, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
