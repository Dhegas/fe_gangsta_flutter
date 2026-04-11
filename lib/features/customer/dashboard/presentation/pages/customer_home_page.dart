import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';
import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Home')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space6),
              const Text(
                'Selamat datang di GANGSTA',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CustomerDashboardPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('Dashboard Toko'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
