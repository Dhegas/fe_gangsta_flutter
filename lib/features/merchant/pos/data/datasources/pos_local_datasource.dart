import 'package:fe_gangsta_flutter/features/merchant/pos/data/models/pos_menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';

class PosLocalDataSource {
  Future<String> getMerchantName() async {
    return 'Bistro Moderne';
  }

  Future<String> getMerchantRoleLabel() async {
    return 'Kitchen Lead';
  }

  Future<List<PosCategory>> getCategories() async {
    return const [
      PosCategory(id: 'all', label: 'All'),
      PosCategory(id: 'main_course', label: 'Main Course'),
      PosCategory(id: 'appetizers', label: 'Appetizers'),
      PosCategory(id: 'drinks', label: 'Drinks'),
      PosCategory(id: 'desserts', label: 'Desserts'),
    ];
  }

  Future<List<PosMenuItemModel>> getMenuItems() async {
    return const [
      PosMenuItemModel(
        id: 'p1',
        name: 'Bakso Super',
        categoryId: 'main_course',
        price: 28500,
        imageUrl:
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=1200',
        isAvailable: true,
      ),
      PosMenuItemModel(
        id: 'p2',
        name: 'Ayam Geprek',
        categoryId: 'main_course',
        price: 25000,
        imageUrl:
            'https://images.unsplash.com/photo-1518492104633-130d0cc84637?w=1200',
        isAvailable: true,
      ),
      PosMenuItemModel(
        id: 'p3',
        name: 'Bistro Burger',
        categoryId: 'main_course',
        price: 32900,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200',
        isAvailable: true,
      ),
      PosMenuItemModel(
        id: 'p4',
        name: 'Garlic Fries',
        categoryId: 'appetizers',
        price: 19000,
        imageUrl:
            'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=1200',
        isAvailable: true,
      ),
      PosMenuItemModel(
        id: 'p5',
        name: 'Lychee Breeze',
        categoryId: 'drinks',
        price: 18000,
        imageUrl:
            'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=1200',
        isAvailable: true,
      ),
      PosMenuItemModel(
        id: 'p6',
        name: 'Volcano Choco',
        categoryId: 'desserts',
        price: 22000,
        imageUrl:
            'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=1200',
        isAvailable: true,
      ),
    ];
  }

  Future<List<String>> getTableLabels() async {
    return const [
      'Takeaway',
      'Table 01',
      'Table 02',
      'Table 03',
      'Table 04',
      'Table 05',
    ];
  }
}
