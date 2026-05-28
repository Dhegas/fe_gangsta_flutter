import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
import 'package:flutter/material.dart';

class GuestInfoBottomSheet extends StatefulWidget {
  const GuestInfoBottomSheet({super.key});

  @override
  State<GuestInfoBottomSheet> createState() => _GuestInfoBottomSheetState();
}

class _GuestInfoBottomSheetState extends State<GuestInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerAccount = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final guest = GuestCustomerEntity(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _registerAccount ? _emailController.text.trim() : null,
        password: _registerAccount ? _passwordController.text : null,
      );
      Navigator.of(context).pop(guest);
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
                'Informasi Pemesan (Tamu)',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Silakan lengkapi data diri Anda untuk melanjutkan pemesanan.',
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
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon / WhatsApp',
                  hintText: 'Contoh: 08123456789',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  final regExp = RegExp(r'^[0-9+]{8,15}$');
                  if (!regExp.hasMatch(value.trim())) {
                    return 'Nomor telepon tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _registerAccount
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.surfaceStrong.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeThumbColor: AppColors.primary,
                      title: Text(
                        'Buat Akun Otomatis',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Simpan data Anda untuk melacak pesanan lebih mudah di masa mendatang.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: _registerAccount,
                      onChanged: (val) {
                        setState(() {
                          _registerAccount = val;
                        });
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _registerAccount
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.space4,
                                right: AppSpacing.space4,
                                bottom: AppSpacing.space4,
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Masukkan alamat email Anda',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (!_registerAccount) return null;
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
                                      if (!_registerAccount) return null;
                                      if (value == null || value.isEmpty) {
                                        return 'Kata sandi wajib diisi';
                                      }
                                      if (value.length < 6) {
                                        return 'Kata sandi minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
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
                  onPressed: _submit,
                  child: const Text(
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
