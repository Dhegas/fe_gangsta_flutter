import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/models/menu_management_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';

class MenuManagementLocalDataSource {
  Future<String> getMerchantName() async {
    return 'Bistro Moderne';
  }

  Future<String> getMerchantRoleLabel() async {
    return 'Kitchen Lead';
  }

  Future<List<MenuManagementCategory>> getCategories() async {
    return const [
      MenuManagementCategory(id: 'all', label: 'All'),
      MenuManagementCategory(id: 'main_course', label: 'Main Course'),
      MenuManagementCategory(id: 'appetizers', label: 'Appetizers'),
      MenuManagementCategory(id: 'drinks', label: 'Drinks'),
      MenuManagementCategory(id: 'desserts', label: 'Desserts'),
    ];
  }

  Future<List<MenuManagementItemModel>> getItems() async {
    return const [
      MenuManagementItemModel(
        id: 'm1',
        name: 'Bakso Super',
        categoryId: 'main_course',
        price: 12.50,
        imageUrl:
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=1200',
        isInStock: true,
      ),
      MenuManagementItemModel(
        id: 'm2',
        name: 'Ayam Geprek',
        categoryId: 'main_course',
        price: 10.00,
        imageUrl:
            'https://images.unsplash.com/photo-1518492104633-130d0cc84637?w=1200',
        isInStock: true,
      ),
      MenuManagementItemModel(
        id: 'm3',
        name: 'Bistro Burger',
        categoryId: 'main_course',
        price: 14.90,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200',
        isInStock: false,
      ),
      MenuManagementItemModel(
        id: 'm4',
        name: 'Lychee Breeze',
        categoryId: 'drinks',
        price: 4.50,
        imageUrl:
            'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=1200',
        isInStock: true,
      ),
      MenuManagementItemModel(
        id: 'm5',
        name: 'Volcano Choco',
        categoryId: 'desserts',
        price: 8.00,
        imageUrl:
            'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=1200',
        isInStock: true,
      ),
    ];
  }
}
