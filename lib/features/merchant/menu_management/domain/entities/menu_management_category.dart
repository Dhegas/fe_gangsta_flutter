class MenuManagementCategory {
  const MenuManagementCategory({
    required this.id,
    required this.label,
    this.isActive = true,
  });

  final String id;
  final String label;
  final bool isActive;

  MenuManagementCategory copyWith({
    String? id,
    String? label,
    bool? isActive,
  }) {
    return MenuManagementCategory(
      id: id ?? this.id,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }
}

