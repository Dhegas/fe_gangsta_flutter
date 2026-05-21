import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/admin/admin_landing_page.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/tenant_selection_page.dart';
import 'package:flutter/material.dart';

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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? _role;

  void _logout() {
    setState(() {
      _role = null;
      ApiClient.activeToken = null;
      ApiClient.activeTenantId = null;
      ApiClient.activeTenantName = null;
    });
  }

  void _login() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AuthPage(
          onAuthenticated: (resolvedRole) {
            setState(() {
              _role = resolvedRole;
            });
            Navigator.of(context).pop(); // Go back from AuthPage
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _role;
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
