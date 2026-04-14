import 'dart:convert';
import 'dart:io';

import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';
import 'package:qr/qr.dart';

void main() {
  final outputDir = Directory('assets/qr_codes');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final manifest = <Map<String, String>>[];

  for (final store in UnifiedDummyStoreData.stores) {
    final payload = UnifiedDummyStoreData.encodeQrPayload(store.id);
    final svg = _buildQrSvg(payload);
    final fileName = '${store.id}.svg';
    final file = File('${outputDir.path}/$fileName');
    file.writeAsStringSync(svg);

    manifest.add({
      'storeId': store.id,
      'storeName': store.name,
      'qrPayload': payload,
      'assetPath': 'assets/qr_codes/$fileName',
    });
  }

  final manifestFile = File('${outputDir.path}/manifest.json');
  manifestFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest),
  );

  final readmeFile = File('${outputDir.path}/README.md');
  readmeFile.writeAsStringSync(
    [
      '# Store QR Codes',
      '',
      'Folder ini berisi QR code SVG untuk semua toko dummy.',
      '',
      'Setiap QR code berisi payload dengan format:',
      '- gangsta://store/<store-id>',
      '',
      'Daftar lengkap ada di file manifest.json.',
      '',
      'Regenerate kapan saja dengan command:',
      '- dart run tool/generate_store_qr_assets.dart',
    ].join('\n'),
  );

  stdout.writeln('Generated ${manifest.length} QR assets in ${outputDir.path}');
}

String _buildQrSvg(String data) {
  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final qrImage = QrImage(qrCode);

  const quietZone = 4;
  final count = qrImage.moduleCount;
  final fullSize = count + (quietZone * 2);
  final buffer = StringBuffer();

  buffer.writeln(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $fullSize $fullSize" shape-rendering="crispEdges">',
  );
  buffer.writeln('<rect width="$fullSize" height="$fullSize" fill="#ffffff"/>');

  for (var y = 0; y < count; y++) {
    for (var x = 0; x < count; x++) {
      if (qrImage.isDark(y, x)) {
        final px = x + quietZone;
        final py = y + quietZone;
        buffer.writeln(
          '<rect x="$px" y="$py" width="1" height="1" fill="#111111"/>',
        );
      }
    }
  }

  buffer.writeln('</svg>');
  return buffer.toString();
}
