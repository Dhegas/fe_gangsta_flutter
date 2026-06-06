import 'dart:ui';
import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreDiscoveryCard extends StatelessWidget {
  const StoreDiscoveryCard({
    required this.store,
    required this.onOpen,
    required this.onShowQr,
    super.key,
  });

  final StoreEntity store;
  final VoidCallback onOpen;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bannerWidget = store.bannerImageUrl.isEmpty
        ? Container(
            color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
            alignment: Alignment.center,
            child: Icon(
              Icons.storefront,
              color: isDarkMode ? const Color(0xFF64748B) : AppColors.textSecondary,
              size: 50,
            ),
          )
        : CachedNetworkImage(
            imageUrl: store.bannerImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: Icon(
                Icons.storefront,
                color: isDarkMode ? const Color(0xFF64748B) : AppColors.textSecondary,
                size: 50,
              ),
            ),
          );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: SizedBox(
        height: 295, // Fits ListView, overridden by GridView constraints
        width: double.infinity,
        child: Stack(
          children: [
            // 1. Background image filling the entire card
            Positioned.fill(
              child: bannerWidget,
            ),
            // 2. Glassmorphic Panel at the bottom housing text & buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode ? Colors.black.withOpacity(0.1) : const Color(0xFFE2E8F0).withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                store.name,
                                style: textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (store.openHours.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Color(0xFF475569),
                                  ),
                                  const SizedBox(width: AppSpacing.space1),
                                  Text(
                                    store.openHours,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          store.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF334155),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onShowQr,
                                icon: const Icon(Icons.qr_code_2, color: Color(0xFF334155)),
                                label: const Text(
                                  'QR',
                                  style: TextStyle(color: Color(0xFF334155)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: const Color(0xFF64748B).withOpacity(0.4),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(0.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onOpen,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Pilih Toko',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 3. Status Badge (BUKA/TUTUP) in top right corner of Card
            Positioned(
              top: AppSpacing.space3,
              right: AppSpacing.space3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: store.isOpen
                      ? AppColors.statusSuccess.withOpacity(0.9)
                      : AppColors.statusError.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  store.isOpen ? 'BUKA' : 'TUTUP',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
