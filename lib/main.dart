import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/admin/admin_landing_page.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:fe_gangsta_flutter/features/auth/presentation/pages/partner_register_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/tenant_selection_page.dart';
import 'package:flutter/material.dart';

class AuthState {
  static final ValueNotifier<UserRole?> roleNotifier = ValueNotifier<UserRole?>(null);

  static void login(UserRole role, String token) {
    ApiClient.activeToken = token;
    roleNotifier.value = role;
  }

  static void logout() {
    ApiClient.activeToken = null;
    ApiClient.activeTenantId = null;
    ApiClient.activeTenantName = null;
    roleNotifier.value = null;
  }
}

void main() {
  runApp(const AuthRootApp());
}

class AuthRootApp extends StatelessWidget {
  const AuthRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gangsta Auth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/register-partner': (context) => const PartnerRegisterPage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    AuthState.roleNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthState.roleNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _logout() {
    AuthState.logout();
  }

  void _login() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AuthPage(
          onAuthenticated: (resolvedRole) {
            // Read token if available
            final token = ApiConfig.token;
            if (token != null) {
              AuthState.login(resolvedRole, token);
            } else {
              AuthState.roleNotifier.value = resolvedRole;
            }
            Navigator.of(context).pop(); // Go back from AuthPage
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthState.roleNotifier.value;
    if (role == null) {
      return CustomerDashboardPage(
        onLoginPressed: _login,
        onLogoutPressed: _logout,
      );
    }

    switch (role) {
      case UserRole.customer:
        return CustomerDashboardPage(
          onLoginPressed: _login,
          onLogoutPressed: _logout,
        );
      case UserRole.partner:
        return MerchantTenantSelectionPage(
          onLogoutPressed: _logout,
        );
      case UserRole.admin:
        return AdminLandingPage(
          onLogoutPressed: _logout,
        );
    }
  }
}
