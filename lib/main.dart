import 'package:fe_gangsta_flutter/design_system/theme/app_theme.dart';
import 'package:fe_gangsta_flutter/features/admin/admin_landing_page.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';
import 'package:fe_gangsta_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_home_page.dart';
import 'package:fe_gangsta_flutter/features/merchant/merchant_landing_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final role = _role;
    if (role == null) {
      return AuthPage(
        onAuthenticated: (resolvedRole) {
          setState(() {
            _role = resolvedRole;
          });
        },
      );
    }

    switch (role) {
      case UserRole.customer:
        return const CustomerHomePage();
      case UserRole.partner:
        return const MerchantLandingPage();
      case UserRole.admin:
        return const AdminLandingPage();
    }
  }
}
