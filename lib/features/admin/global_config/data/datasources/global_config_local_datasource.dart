import 'package:fe_gangsta_flutter/features/admin/global_config/data/models/global_config_model.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';

class GlobalConfigLocalDataSource {
  GlobalConfigModel _mockConfig = const GlobalConfigModel(
    platformFeePercentage: 2.5,
    taxPercentage: 11.0,
    maintenanceMode: false,
    enableNewRegistrations: true,
    supportEmail: 'support@culinaryos.id',
    supportPhone: '+62 811-1234-5678',
    termsUrl: 'https://culinaryos.id/terms',
    privacyPolicyUrl: 'https://culinaryos.id/privacy',
  );

  Future<GlobalConfigModel> getConfig() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockConfig;
  }

  Future<void> updateConfig(GlobalConfigEntity config) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _mockConfig = GlobalConfigModel(
      platformFeePercentage: config.platformFeePercentage,
      taxPercentage: config.taxPercentage,
      maintenanceMode: config.maintenanceMode,
      enableNewRegistrations: config.enableNewRegistrations,
      supportEmail: config.supportEmail,
      supportPhone: config.supportPhone,
      termsUrl: config.termsUrl,
      privacyPolicyUrl: config.privacyPolicyUrl,
    );
  }
}
