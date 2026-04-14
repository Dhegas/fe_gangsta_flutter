import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/presentation/pages/membership_list_page.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/pages/tenant_list_page.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/presentation/pages/billing_overview_page.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/presentation/pages/user_list_page.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/presentation/pages/global_config_page.dart';
import 'package:flutter/material.dart';

class AdminLandingPage extends StatefulWidget {
  const AdminLandingPage({super.key});

  @override
  State<AdminLandingPage> createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    TenantListPage(),
    MembershipListPage(),
    BillingOverviewPage(),
    UserListPage(),
    GlobalConfigPage(),
  ];

  static const _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Tenants',
    ),
    _NavItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium_rounded,
      label: 'Membership',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Billing',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Users',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const _bottomItems = [
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
    _NavItem(
      icon: Icons.help_outline_rounded,
      activeIcon: Icons.help_rounded,
      label: 'Support',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Show side rail on wide screens (>=600), bottom bar on narrow (mobile)
    final isWide = screenWidth >= 600;

    if (!isWide) {
      return _buildMobileLayout();
    }
    return _buildWideLayout();
  }

  // ── Wide layout with left sidebar ──────────────────────────────────────────
  Widget _buildWideLayout() {
    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      body: Row(
        children: [
          _SideRail(
            currentIndex: _currentIndex,
            navItems: _navItems,
            bottomItems: _bottomItems,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout with bottom nav ──────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.surfaceNeutral,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surfaceBase,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon, color: AppColors.primary),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

// ─── Side rail ────────────────────────────────────────────────────────────────
class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.currentIndex,
    required this.navItems,
    required this.bottomItems,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> navItems;
  final List<_NavItem> bottomItems;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 200,
      color: AppColors.surfaceBase,
      child: CustomScrollView(
        slivers: [
          // ── Logo / Branding ────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space5,
                  AppSpacing.space4,
                  AppSpacing.space6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CulinaryOS',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'SUPER ADMIN',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main nav items ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...navItems.asMap().entries.map((entry) {
                    return _NavTile(
                      item: entry.value,
                      isSelected: entry.key == currentIndex,
                      onTap: () => onTap(entry.key),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Bottom utility nav & Profile ───────────────────────
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
                  child: Column(
                    children: [
                      const Divider(color: AppColors.surfaceSoft, height: 24),
                      Text(
                        'SUPPORT & TOOLS',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      ...bottomItems.map((item) => _NavTile(
                            item: item,
                            isSelected: false,
                            onTap: () {},
                          )),
                    ],
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Master',
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'System Root',
                                  style: tt.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single nav tile ──────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: AppSpacing.space1),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.space3),
            Text(
              item.label,
              style: tt.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
