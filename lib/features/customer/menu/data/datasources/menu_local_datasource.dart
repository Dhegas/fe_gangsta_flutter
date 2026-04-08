import 'package:fe_gangsta_flutter/features/customer/menu/data/models/menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';

class MenuLocalDataSource {
  Future<String> getStoreName() async {
    return 'Bakso Pak Slamet';
  }

  Future<List<MenuCategory>> getCategories() async {
    return const [
      MenuCategory(id: 'all', name: 'Semua'),
      MenuCategory(id: 'bakso', name: 'Bakso'),
      MenuCategory(id: 'mie', name: 'Mie'),
      MenuCategory(id: 'minuman', name: 'Minuman'),
      MenuCategory(id: 'snack', name: 'Snack'),
    ];
  }

  Future<List<MenuItemModel>> getMenuItems() async {
    return const [
      MenuItemModel(
        id: 'm1',
        categoryId: 'bakso',
        name: 'Bakso Urat Jumbo',
        description: 'Bakso urat kenyal dengan kuah kaldu sapi gurih.',
        price: 26000,
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=1200',
      ),
      MenuItemModel(
        id: 'm2',
        categoryId: 'bakso',
        name: 'Bakso Telur Spesial',
        description: 'Bakso isi telur, bihun, sawi, dan bawang goreng.',
        price: 24000,
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=1200',
      ),
      MenuItemModel(
        id: 'm3',
        categoryId: 'mie',
        name: 'Mie Ayam Komplit',
        description: 'Mie kenyal, ayam manis gurih, pangsit, dan sawi.',
        price: 22000,
        imageUrl:
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200',
      ),
      MenuItemModel(
        id: 'm4',
        categoryId: 'mie',
        name: 'Mie Yamin Pedas',
        description: 'Mie yamin manis pedas dengan topping ayam cincang.',
        price: 23000,
        imageUrl:
            'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=1200',
      ),
      MenuItemModel(
        id: 'm5',
        categoryId: 'minuman',
        name: 'Es Teh Manis',
        description: 'Teh melati dingin, manis dan segar.',
        price: 7000,
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=1200',
      ),
      MenuItemModel(
        id: 'm6',
        categoryId: 'minuman',
        name: 'Jeruk Peras',
        description: 'Jeruk peras asli tanpa pemanis buatan.',
        price: 11000,
        imageUrl:
            'https://images.unsplash.com/photo-1603569283847-aa295f0d016a?w=1200',
      ),
      MenuItemModel(
        id: 'm7',
        categoryId: 'snack',
        name: 'Pangsit Goreng',
        description: 'Pangsit ayam goreng renyah isi 5 pcs.',
        price: 14000,
        imageUrl:
            'https://images.unsplash.com/photo-1623238913973-21e45cced554?w=1200',
      ),
    ];
  }
}
