import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:flutter/material.dart';

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

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            child: store.bannerImageUrl.isEmpty
                ? Container(
                    height: 110,
                    color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.storefront,
                      color: isDarkMode ? const Color(0xFF64748B) : AppColors.textSecondary,
                      size: 40,
                    ),
                  )
                : Image.network(
                    store.bannerImageUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 110,
                      color: isDarkMode ? const Color(0xFF1E293B) : AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.storefront,
                        color: isDarkMode ? const Color(0xFF64748B) : AppColors.textSecondary,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        store.name,
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: store.isOpen
                            ? AppColors.statusSuccess.withOpacity(0.1)
                            : AppColors.statusError.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        store.isOpen ? 'BUKA' : 'TUTUP',
                        style: textTheme.labelSmall?.copyWith(
                          color: store.isOpen
                              ? AppColors.statusSuccess
                              : AppColors.statusError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  store.description,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (store.openHours.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.space1),
                      Text(
                        store.openHours,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.space3),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onShowQr,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('QR'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onOpen,
                        child: const Text('Pilih Toko'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
