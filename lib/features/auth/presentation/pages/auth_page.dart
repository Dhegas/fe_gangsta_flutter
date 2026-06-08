import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.onAuthenticated,
  });

  final ValueChanged<UserRole> onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _httpClient = http.Client();
  bool _isLogin = true;
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

  void _toggleMode(bool isLogin) {
    if (_isLogin == isLogin) {
      return;
    }

    setState(() {
      _isLogin = isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
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
      final role = _isLogin
          ? await _authRepository.login(
              email: normalizedEmail,
              password: _passwordController.text,
            )
          : await _authRepository.register(
              fullName: _fullNameController.text.trim(),
              email: normalizedEmail,
              password: _passwordController.text,
            );

      if (!mounted) {
        return;
      }

      widget.onAuthenticated(role);
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
        _errorMessage = 'Login gagal: ${error.toString()}';
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _AuthCardContent(state: this),
                ),
              ),
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



class _AuthCardContent extends StatelessWidget {
  const _AuthCardContent({required this.state});

  final _AuthPageState state;

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
              _ModeToggle(
                isLogin: state._isLogin,
                onSelect: state._toggleMode,
              ),
              const SizedBox(height: AppSpacing.space6),
              Text(
                state._isLogin ? 'Selamat datang kembali' : 'Buat akun baru',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                state._isLogin
                    ? 'Login membutuhkan email dan password sesuai spesifikasi API.'
                    : 'Registrasi membutuhkan full name, email, dan password sesuai API.',
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
              if (!state._isLogin) ...[
                TextFormField(
                  controller: state._fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    hintText: 'Nama lengkap',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space4),
              ],
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
                      : Text(state._isLogin ? 'Masuk' : 'Daftar'),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        state._isLogin
                            ? 'Belum punya akun?'
                            : 'Sudah punya akun?',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => state._toggleMode(!state._isLogin),
                        child: Text(state._isLogin ? 'Daftar' : 'Login'),
                      ),
                    ],
                  ),
                  if (state._isLogin)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register-partner');
                      },
                      child: const Text('Daftar Partner'),
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

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isLogin, required this.onSelect});

  final bool isLogin;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Login',
            isSelected: isLogin,
            onTap: () => onSelect(true),
            textTheme: textTheme,
          ),
          _ToggleOption(
            label: 'Register',
            isSelected: !isLogin,
            onTap: () => onSelect(false),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceBase)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: isSelected
              ? Border.all(
                  color: isDarkMode ? const Color(0xFF334155) : AppColors.surfaceStrong,
                )
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
            child: Center(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? (isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary)
                      : (isDarkMode ? const Color(0xFF64748B) : AppColors.textMuted),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
