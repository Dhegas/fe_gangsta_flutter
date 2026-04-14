import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({super.key, required this.user});

  final UserEntity user;

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
        return const Color(0xFF3B82F6);
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtDate(DateTime dt) => DateFormat('dd MMMM yyyy, HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('User Profile',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space6),
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
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceStrong),
                      ),
                      child: Text(
                        user.avatarInitials ?? 'U',
                        style: tt.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(user.name,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.space1),
                    Text(user.email,
                        style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),

              // ── Details ──────────────────────────────────────────
              Text('ACCOUNT DETAILS',
                  style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary, letterSpacing: 1)),
              const SizedBox(height: AppSpacing.space3),
              Container(
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
                  children: [
                    _DetailRow(label: 'User ID', value: user.id, tt: tt),
                    if (user.tenantName != null) ...[
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _DetailRow(
                          label: 'Associated Tenant',
                          value: user.tenantName!,
                          tt: tt,
                          valueColor: AppColors.primary),
                    ],
                    if (user.tenantId != null) ...[
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      _DetailRow(label: 'Tenant ID', value: user.tenantId!, tt: tt),
                    ],
                    const Divider(color: AppColors.surfaceSoft, height: 24),
                    _DetailRow(
                        label: 'Creation Date',
                        value: _fmtDate(user.createdAt),
                        tt: tt),
                    const Divider(color: AppColors.surfaceSoft, height: 24),
                    _DetailRow(
                        label: 'Last Login',
                        value: user.lastLogin != null
                            ? _fmtDate(user.lastLogin!)
                            : 'N/A',
                        tt: tt),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // ── Actions ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit User Role & Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_reset_rounded, size: 16),
                  label: const Text('Reset Password'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.surfaceStrong),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                ),
              ),
              if (user.status != 'suspended' && user.role != 'admin') ...[
                const SizedBox(height: AppSpacing.space3),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.block_rounded, size: 16),
                    label: const Text('Suspend Account'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.statusError,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.tt,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextTheme tt;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
