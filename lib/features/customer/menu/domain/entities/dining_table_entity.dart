class DiningTableEntity {
  const DiningTableEntity({
    required this.id,
    required this.tenantId,
    required this.tableName,
    required this.status,
  });

  final String id;
  final String tenantId;
  final String tableName;
  final String status;
}
