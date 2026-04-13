import 'package:fe_gangsta_flutter/app/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const RoleSelectorApp());
}

class RoleSelectorApp extends StatelessWidget {
  const RoleSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role Selector',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pilih Role (Dev Mode)'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  runApp(const GangstaApp.customer());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Buka sebagai Customer'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  runApp(const GangstaApp.merchant());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Buka sebagai Merchant'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  runApp(const GangstaApp.admin());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Buka sebagai Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
