import 'package:fe_gangsta_flutter/core/network/api_client.dart' as net;
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart' as global_api;
import 'package:http/http.dart' as http;
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
import 'package:fe_gangsta_flutter/main.dart' show AuthState;
import 'package:flutter/material.dart';

class GuestInfoBottomSheet extends StatefulWidget {
  const GuestInfoBottomSheet({super.key});

  @override
  State<GuestInfoBottomSheet> createState() => _GuestInfoBottomSheetState();
}

class _GuestInfoBottomSheetState extends State<GuestInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final fullName = _nameController.text.trim();

      try {
        final netClient = net.ApiClient(
          client: http.Client(),
          getAccessToken: () => global_api.ApiClient.activeToken,
        );
        final authRepository = AuthRepositoryImpl(AuthRemoteDataSource(netClient));
        await authRepository.register(
          fullName: fullName,
          email: email,
          password: password,
          role: 'CUSTOMER',
        );

        // Log in the user immediately to get the access token
        await authRepository.login(
          email: email,
          password: password,
        );

        // Sync global ApiClient token
        global_api.ApiClient.activeToken = ApiConfig.token;
        
        // Notify application main widget of the login state
        AuthState.login(UserRole.customer, ApiConfig.token ?? '', ApiConfig.refreshToken ?? '');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          final guest = GuestCustomerEntity(
            fullName: fullName,
            phoneNumber: "",
            email: email,
            password: password,
          );

          Navigator.of(context).pop(guest);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('AuthFailure: ', '')),
              backgroundColor: AppColors.statusError,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final padding = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space5,
        right: AppSpacing.space5,
        top: AppSpacing.space5,
        bottom: padding.bottom + AppSpacing.space5,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Registrasi Pemesanan Tamu',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Silakan lengkapi data diri Anda untuk membuat akun baru dan melanjutkan pemesanan.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama lengkap minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space3),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan alamat email Anda',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  final emailRegExp =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegExp.hasMatch(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space3),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi (Password)',
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Kata sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Lanjutkan ke Pembayaran',
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
}
