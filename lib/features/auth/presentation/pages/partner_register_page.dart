import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/main.dart' show AuthState;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PartnerRegisterPage extends StatefulWidget {
  const PartnerRegisterPage({super.key});

  @override
  State<PartnerRegisterPage> createState() => _PartnerRegisterPageState();
}

class _PartnerRegisterPageState extends State<PartnerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _httpClient = http.Client();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(
        ApiClient(client: _httpClient),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _httpClient.close();
    super.dispose();
  }

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final normalizedEmail = _emailController.text.trim().toLowerCase();

    try {
      final role = await _authRepository.register(
        fullName: _fullNameController.text.trim(),
        email: normalizedEmail,
        password: _passwordController.text,
        role: 'PARTNER',
      );

      if (!mounted) {
        return;
      }

      // Automatically log the user in using the token saved in ApiConfig.token
      final token = ApiConfig.token;
      final refreshToken = ApiConfig.refreshToken;
      if (token != null && refreshToken != null) {
        AuthState.login(role, token, refreshToken);
      } else if (token != null) {
        AuthState.login(role, token, '');
      }

      // Navigate back to the home route which will render the tenant selection page
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Registrasi gagal: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _BackgroundGlow(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 960;
                final content = isDesktop
                    ? Row(
                        children: [
                          const Expanded(child: _BrandPanel()),
                          Expanded(child: _RegisterCardContent(state: this)),
                        ],
                      )
                    : Column(
                        children: [
                          const _BrandPanel(isCompact: true),
                          _RegisterCardContent(state: this),
                        ],
                      );

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space6),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF0B0F19),
                      const Color(0xFF020617),
                    ]
                  : [
                      const Color(0xFFFFF3ED),
                      const Color(0xFFFFF9F0),
                      const Color(0xFFF6FBF8),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -120,
          child: _GlowCircle(
            color: AppColors.primary.withOpacity(isDarkMode ? 0.08 : 0.2),
            size: 260,
          ),
        ),
        Positioned(
          bottom: -140,
          left: -80,
          child: _GlowCircle(
            color: AppColors.secondary.withOpacity(isDarkMode ? 0.08 : 0.2),
            size: 280,
          ),
        ),
        Positioned(
          top: 180,
          left: 120,
          child: _GlowCircle(
            color: AppColors.tertiary.withOpacity(isDarkMode ? 0.06 : 0.15),
            size: 140,
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        right: isCompact ? 0 : AppSpacing.space8,
        bottom: isCompact ? AppSpacing.space6 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF334155) : AppColors.surfaceStrong,
              ),
            ),
            child: Text(
              'Gangsta Partner',
              style: textTheme.titleMedium?.copyWith(
                color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            'Kembangkan bisnis kuliner Anda bersama kami.',
            style: textTheme.displaySmall?.copyWith(
              color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
              fontSize: isCompact ? 26 : null,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Kelola restoran, POS, menu, meja, transaksi, dan analisis laporan penjualan real-time dalam satu platform SaaS terintegrasi.',
            style: textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          _FeatureRow(
            title: 'POS & Meja Pintar',
            description: 'Kelola menu, status meja, dan order dari satu dashboard secara real-time.',
          ),
          const SizedBox(height: AppSpacing.space4),
          _FeatureRow(
            title: 'Real-time Reporting & Analytics',
            description: 'Pantau grafik pendapatan harian, menu terlaris, dan kinerja meja kasir.',
          ),
          const SizedBox(height: AppSpacing.space4),
          _FeatureRow(
            title: 'Multi-outlet & Tenant Aman',
            description: 'Akses data outlet dipisahkan secara aman per tenant dengan sistem token.',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? const Color(0xFFF1F5F9) : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterCardContent extends StatelessWidget {
  const _RegisterCardContent({required this.state});

  final _PartnerRegisterPageState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Form(
          key: state._formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar sebagai Partner',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'Buat akun baru untuk mulai mengelola outlet kuliner Anda sendiri di Gangsta.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8)
                      : AppColors.textSecondary,
                ),
              ),
              if (state._errorMessage != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.statusError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.statusError),
                  ),
                  child: Text(
                    state._errorMessage ?? '',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.statusError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space6),
              TextFormField(
                controller: state._fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama Lengkap wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space4),
              TextFormField(
                controller: state._emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space4),
              TextFormField(
                controller: state._passwordController,
                obscureText: state._obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimal 6 karakter',
                  suffixIcon: IconButton(
                    onPressed: state._toggleObscurePassword,
                    icon: Icon(
                      state._obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi.';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space6),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state._isSubmitting ? null : state._submit,
                  child: state._isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Daftar sebagai Partner'),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun?',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
