class WaitlistEntryEntity {
  const WaitlistEntryEntity({
    required this.name,
    required this.pax,
    required this.etaMinutes,
  });

  final String name;
  final int pax;
  final int etaMinutes;
}
