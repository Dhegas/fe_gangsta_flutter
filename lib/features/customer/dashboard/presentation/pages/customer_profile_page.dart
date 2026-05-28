import 'package:fe_gangsta_flutter/core/network/api_client.dart' as net_api;
import 'package:fe_gangsta_flutter/core/services/api_client.dart' as global_api;
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_profile_entity.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({
    this.onLogoutPressed,
    super.key,
  });

  final VoidCallback? onLogoutPressed;

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  late final AuthRepository _authRepository;
  UserProfileEntity? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Instansiasi API Client & Auth Repository
    final netClient = net_api.ApiClient(
      client: http.Client(),
      getAccessToken: () => global_api.ApiClient.activeToken,
    );
    _authRepository = AuthRepositoryImpl(AuthRemoteDataSource(netClient));
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _authRepository.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('AuthFailure(message: ', '').replaceAll(')', '');
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.statusError,
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          ElevatedButton.icon(
                            onPressed: _fetchProfile,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.space3),
                        // Avatar dengan Inisial Premium
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(_profile?.fullName ?? ''),
                                style: textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        // Nama Pengguna
                        Text(
                          _profile?.fullName ?? 'User',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        // Badge Role
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space3,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            (_profile?.role ?? 'CUSTOMER').toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space6),
                        // Card Detail Akun
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.space4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: AppColors.surfaceStrong.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileRow(
                                context,
                                Icons.person_outline_rounded,
                                'Nama Lengkap',
                                _profile?.fullName ?? '-',
                              ),
                              const Divider(height: AppSpacing.space4),
                              _buildProfileRow(
                                context,
                                Icons.email_outlined,
                                'Alamat Email',
                                _profile?.email ?? '-',
                              ),
                              const Divider(height: AppSpacing.space4),
                              _buildProfileRow(
                                context,
                                Icons.phone_android_rounded,
                                'Nomor Telepon',
                                (_profile?.phoneNumber != null && _profile!.phoneNumber.isNotEmpty)
                                    ? _profile!.phoneNumber
                                    : '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space6),
                        // Tombol Logout
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.statusError,
                              side: const BorderSide(color: AppColors.statusError, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.space3,
                              ),
                            ),
                            onPressed: () {
                              if (widget.onLogoutPressed != null) {
                                widget.onLogoutPressed!();
                                Navigator.of(context).pop(); // Tutup halaman profil
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Keluar dari Akun',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space2),
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
