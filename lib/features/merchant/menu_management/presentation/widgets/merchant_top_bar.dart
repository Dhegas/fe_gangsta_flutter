import 'dart:ui';

import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/main.dart';
import 'package:fe_gangsta_flutter/features/merchant/tenant_selection_page.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:flutter/material.dart';

class MerchantTopBar extends StatefulWidget {
  const MerchantTopBar({
    super.key,
    required this.onSearchChanged,
    this.searchQuery = '',
    this.isCompact = false,
    this.showSearchBar = true,
  });

  final ValueChanged<String> onSearchChanged;
  final String searchQuery;
  final bool isCompact;
  final bool showSearchBar;

  @override
  State<MerchantTopBar> createState() => _MerchantTopBarState();
}

class _MerchantTopBarState extends State<MerchantTopBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant MerchantTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.72) : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14191C1E),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.isCompact) ...[
                IconButton(
                  onPressed: () {
                    navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (context) => MerchantTenantSelectionPage(
                          onLogoutPressed: () {
                            AuthState.logout();
                            navigatorKey.currentState?.pushReplacementNamed('/');
                          },
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
                  tooltip: 'Pilih Outlet Lain',
                ),
                const SizedBox(width: AppSpacing.space2),
              ],
              if (widget.showSearchBar) ...[
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceNeutral,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                        hintText: 'Search menu items...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? const Color(0xFF64748B) : AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _buildDesktopTenantProfile(context, isDarkMode),
                const Spacer(),
              ],
              if (widget.isCompact) ...[
                if (widget.showSearchBar) ...[
                  const SizedBox(width: AppSpacing.space2),
                  _buildTenantProfile(context, isDarkMode),
                ],
              ] else ...[
                const SizedBox(width: AppSpacing.space4),
                const _TopActionIcon(icon: Icons.notifications_none_outlined),
                const SizedBox(width: AppSpacing.space2),
                const _TopActionIcon(icon: Icons.help_outline_rounded),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenantProfile(BuildContext context, bool isDarkMode) {
    final tenantName = ApiClient.activeTenantName ?? 'Toko';
    final initial = tenantName.isNotEmpty ? tenantName[0].toUpperCase() : 'T';
    final screenWidth = MediaQuery.of(context).size.width;
    final showName = screenWidth >= 480;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showName) ...[
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              tenantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Tooltip(
          message: tenantName,
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.15),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF475569) : AppColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTenantProfile(BuildContext context, bool isDarkMode) {
    final tenantName = ApiClient.activeTenantName ?? 'Toko';
    return Row(
      children: [
        Icon(
          Icons.storefront_rounded,
          color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          tenantName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
      ),
    );
  }
}
