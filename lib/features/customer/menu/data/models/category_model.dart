import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';

class CategoryModel extends MenuCategory {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
