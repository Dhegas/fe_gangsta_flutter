class GlobalConfigEntity {
  const GlobalConfigEntity({
    required this.platformFeePercentage,
    required this.taxPercentage,
    required this.maintenanceMode,
    required this.enableNewRegistrations,
    required this.supportEmail,
    required this.supportPhone,
    required this.termsUrl,
    required this.privacyPolicyUrl,
  });

  final double platformFeePercentage;
  final double taxPercentage;
  final bool maintenanceMode;
  final bool enableNewRegistrations;
  final String supportEmail;
  final String supportPhone;
  final String termsUrl;
  final String privacyPolicyUrl;
}
