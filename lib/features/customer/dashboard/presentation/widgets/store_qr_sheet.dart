import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/utils/store_qr_codec.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StoreQrSheet extends StatelessWidget {
  const StoreQrSheet({required this.store, super.key});

  final StoreEntity store;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final qrData = StoreQrCodec.encodeStoreId(store.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('QR Toko', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.space1),
            Text(
              store.name,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: QrImageView(
                data: qrData,
                size: 220,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              'Scan QR ini dari fitur Scan QR Toko untuk langsung masuk ke menu merchant.',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
