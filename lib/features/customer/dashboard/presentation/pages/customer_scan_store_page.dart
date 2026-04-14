import 'package:fe_gangsta_flutter/features/customer/menu/presentation/pages/customer_menu_digital_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/utils/store_qr_codec.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CustomerScanStorePage extends StatefulWidget {
  const CustomerScanStorePage({required this.validStoreIds, super.key});

  final Set<String> validStoreIds;

  @override
  State<CustomerScanStorePage> createState() => _CustomerScanStorePageState();
}

class _CustomerScanStorePageState extends State<CustomerScanStorePage> {
  bool _isHandled = false;

  void _handleCode(String rawCode) {
    if (_isHandled) {
      return;
    }

    final storeId = StoreQrCodec.decodeStoreId(rawCode);
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format QR tidak dikenali. Gunakan QR toko yang valid.',
          ),
        ),
      );
      return;
    }

    if (!widget.validStoreIds.contains(storeId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'QR toko tidak valid. Coba QR dari merchant yang terdaftar.',
          ),
        ),
      );
      return;
    }

    _isHandled = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CustomerMenuDigitalPage(storeId: storeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Toko')),
      body: MobileScanner(
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final rawValue = barcode.rawValue;
            if (rawValue != null && rawValue.isNotEmpty) {
              _handleCode(rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
