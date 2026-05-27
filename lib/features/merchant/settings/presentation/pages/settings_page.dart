import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:fe_gangsta_flutter/main.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final MerchantNavItem _selectedNav = MerchantNavItem.settings;

  void _handleNavTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }
    navigateToMerchantSection(context, item, _selectedNav);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: isDesktop
          ? null
          : MerchantBottomNav(
              selectedItem: _selectedNav,
              onTapItem: _handleNavTap,
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              MerchantSidebar(
                merchantName: ApiClient.activeTenantName ?? 'Toko',
                merchantRoleLabel: 'Owner',
                selectedItem: _selectedNav,
                onTapItem: _handleNavTap,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                  AppSpacing.space4,
                  isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                  AppSpacing.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MerchantTopBar(
                      onSearchChanged: (_) {},
                      isCompact: !isTablet,
                      showSearchBar: false,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    Text(
                      'Settings',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Kelola preferensi aplikasi dan tampilan di sini.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.space5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? AppColors.surfaceBase,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF334155) : AppColors.surfaceStrong,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tampilan & Tema',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            ValueListenableBuilder<ThemeMode>(
                              valueListenable: ThemeState.themeModeNotifier,
                              builder: (context, currentMode, child) {
                                final isDark = currentMode == ThemeMode.dark;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => ThemeState.toggleTheme(false),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                                          decoration: BoxDecoration(
                                            color: !isDark
                                                ? (isDarkMode ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.1))
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: !isDark
                                                  ? AppColors.primary
                                                  : (isDarkMode ? const Color(0xFF334155) : AppColors.surfaceStrong),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(AppRadius.lg),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.light_mode_rounded,
                                                color: !isDark
                                                    ? AppColors.primary
                                                    : (isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted),
                                                size: 24,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Mode Terang',
                                                style: textTheme.labelLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: !isDark
                                                      ? AppColors.primary
                                                      : (isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.space4),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => ThemeState.toggleTheme(true),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? (isDarkMode ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.1))
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isDark
                                                  ? AppColors.primary
                                                  : (isDarkMode ? const Color(0xFF334155) : AppColors.surfaceStrong),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(AppRadius.lg),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.dark_mode_rounded,
                                                color: isDark
                                                    ? AppColors.primary
                                                    : (isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted),
                                                size: 24,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Mode Gelap',
                                                style: textTheme.labelLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? AppColors.primary
                                                      : (isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
