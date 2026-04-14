import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';

class GlobalConfigModel extends GlobalConfigEntity {
  const GlobalConfigModel({
    required super.platformFeePercentage,
    required super.taxPercentage,
    required super.maintenanceMode,
    required super.enableNewRegistrations,
    required super.supportEmail,
    required super.supportPhone,
    required super.termsUrl,
    required super.privacyPolicyUrl,
  });
}
