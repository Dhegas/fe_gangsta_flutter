import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class StoreQrCodec {
  const StoreQrCodec._();

  static String encodeStoreId(String storeId) {
    return UnifiedDummyStoreData.encodeQrPayload(storeId);
  }

  static String? decodeStoreId(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final directId = _cleanId(trimmed);
    if (directId != null) {
      return directId;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }

    final queryCandidates = <String?>[
      uri.queryParameters['store_id'],
      uri.queryParameters['storeId'],
      uri.queryParameters['id'],
    ];
    for (final candidate in queryCandidates) {
      final cleaned = _cleanId(candidate);
      if (cleaned != null) {
        return cleaned;
      }
    }

    if (uri.scheme == 'gangsta' && uri.host == 'store') {
      final pathId = _cleanId(
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null,
      );
      if (pathId != null) {
        return pathId;
      }
    }

    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'store') {
      final pathId = _cleanId(uri.pathSegments[1]);
      if (pathId != null) {
        return pathId;
      }
    }

    return null;
  }

  static String? _cleanId(String? value) {
    if (value == null) {
      return null;
    }

    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) {
      return null;
    }

    final isValid = RegExp(r'^[a-z0-9-]+$').hasMatch(cleaned);
    return isValid ? cleaned : null;
  }
}
