import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/datasources/menu_management_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/repositories/menu_management_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/controllers/menu_management_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/add_new_product_card.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/menu_management_category_tabs.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_menu_item_card.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  late final MenuManagementController _controller;

  @override
  void initState() {
    super.initState();

    final repository = MenuManagementRepositoryImpl(MenuManagementLocalDataSource());

    _controller = MenuManagementController(repository)
      ..addListener(_onControllerUpdate)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerUpdate)
      ..dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          bottomNavigationBar: isDesktop
              ? null
              : MerchantBottomNav(
                  selectedItem: MerchantNavItem.menuManagement,
                  onTapItem: _handleSidebarTap,
                ),
          body: SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      if (isDesktop)
                        MerchantSidebar(
                          merchantName: state.merchantName,
                          merchantRoleLabel: state.merchantRoleLabel,
                          selectedItem: MerchantNavItem.menuManagement,
                          onTapItem: _handleSidebarTap,
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                            AppSpacing.space4,
                            isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                            AppSpacing.space4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MerchantTopBar(
                                onSearchChanged: _controller.updateSearch,
                                isCompact: !isDesktop,
                              ),
                              const SizedBox(height: AppSpacing.space6),
                              _HeaderSection(
                                onAddTap: () => _openItemForm(),
                                onSortTap: _openSortSheet,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              MenuManagementCategoryTabs(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onSelected: _controller.updateCategory,
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              Expanded(
                                child: _MenuGrid(
                                  items: _controller.filteredItems,
                                  categories: state.categories,
                                  onToggleStock: _controller.toggleStock,
                                  onToggleActive: _controller.toggleActive,
                                  onSimulateOrder: _controller.simulateIncomingOrder,
                                  onAddCardTap: () => _openItemForm(),
                                  onEditItem: (item) => _openItemForm(existing: item),
                                  onDeleteItem: _confirmDelete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _openItemForm({MenuManagementItemEntity? existing}) async {
    final result = await showDialog<_MenuFormResult>(
      context: context,
      builder: (context) => _MenuItemFormDialog(
        categories: _controller.state.categories.where((c) => c.id != 'all').toList(),
        existing: existing,
      ),
    );

    if (result == null) {
      return;
    }

    if (existing == null) {
      _controller.addItem(result.toEntity(id: 'item_${DateTime.now().millisecondsSinceEpoch}'));
      _showToast('Item baru berhasil ditambahkan.');
      return;
    }

    _controller.updateItem(result.toEntity(id: existing.id, sortOrder: existing.sortOrder));
    _showToast('Item berhasil diperbarui.');
  }

  Future<void> _confirmDelete(MenuManagementItemEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus item?'),
        content: Text('Item ${item.name} akan dihapus dari katalog.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    _controller.deleteItem(item.id);
    _showToast('Item berhasil dihapus.');
  }

  Future<void> _openSortSheet() async {
    final items = List<MenuManagementItemEntity>.from(_controller.state.items)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'Custom Sorting (Drag & Drop)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.space2),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final entry = items.removeAt(oldIndex);
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        items.insert(newIndex, entry);
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        key: ValueKey(item.id),
                        title: Text(item.name),
                        subtitle: Text('Urutan ${index + 1}'),
                        trailing: const Icon(Icons.drag_indicator),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _controller.applySortByIds(items.map((item) => item.id).toList());
                            Navigator.of(context).pop();
                            _showToast('Urutan menu berhasil diperbarui.');
                          },
                          child: const Text('Simpan Urutan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSidebarTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }

    navigateToMerchantSection(context, item, MerchantNavItem.menuManagement);
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.onAddTap, required this.onSortTap});

  final VoidCallback onAddTap;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      runSpacing: AppSpacing.space3,
      spacing: AppSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Management',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Kelola item, varian, add-ons, promo, stok, dan urutan tampil menu.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            OutlinedButton.icon(
              onPressed: onSortTap,
              icon: const Icon(Icons.swap_vert),
              label: const Text('Custom Sorting'),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFAB3500), AppColors.primary],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add New Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.items,
    required this.categories,
    required this.onToggleStock,
    required this.onToggleActive,
    required this.onSimulateOrder,
    required this.onAddCardTap,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  final List<MenuManagementItemEntity> items;
  final List<MenuManagementCategory> categories;
  final void Function(String itemId, bool isInStock) onToggleStock;
  final void Function(String itemId, bool isActive) onToggleActive;
  final void Function(String itemId) onSimulateOrder;
  final VoidCallback onAddCardTap;
  final ValueChanged<MenuManagementItemEntity> onEditItem;
  final ValueChanged<MenuManagementItemEntity> onDeleteItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;
        final maxCardWidth = constraints.maxWidth >= 1320
            ? 320.0
            : constraints.maxWidth >= 1040
                ? 300.0
                : constraints.maxWidth >= 680
                    ? 280.0
                    : 340.0;
        final childAspectRatio = constraints.maxWidth >= 1320
            ? 0.62
            : constraints.maxWidth >= 1040
                ? 0.60
                : constraints.maxWidth >= 680
                    ? 0.58
                    : 0.66;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: isDesktop
              ? const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.space4,
                  mainAxisSpacing: AppSpacing.space4,
                  childAspectRatio: 0.45,
                )
              : SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCardWidth,
                  crossAxisSpacing: AppSpacing.space4,
                  mainAxisSpacing: AppSpacing.space4,
                  childAspectRatio: childAspectRatio,
                ),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return AddNewProductCard(onTap: onAddCardTap);
            }

            final item = items[index];
            final category = categories.where((c) => c.id == item.categoryId);
            final categoryLabel = category.isEmpty ? 'Uncategorized' : category.first.label;

            return MerchantMenuItemCard(
              item: item,
              categoryLabel: categoryLabel,
              onToggleStock: (isInStock) => onToggleStock(item.id, isInStock),
              onToggleActive: (isActive) => onToggleActive(item.id, isActive),
              onSimulateOrder: () => onSimulateOrder(item.id),
              onEdit: () => onEditItem(item),
              onDelete: () => onDeleteItem(item),
            );
          },
        );
      },
    );
  }
}

class _MenuItemFormDialog extends StatefulWidget {
  const _MenuItemFormDialog({required this.categories, this.existing});

  final List<MenuManagementCategory> categories;
  final MenuManagementItemEntity? existing;

  @override
  State<_MenuItemFormDialog> createState() => _MenuItemFormDialogState();
}

class _MenuItemFormDialogState extends State<_MenuItemFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _discountPriceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _remainingController;
  late final TextEditingController _variantsController;
  late final TextEditingController _addonsController;
  late final TextEditingController _customNotesController;
  late final TextEditingController _dineInController;
  late final TextEditingController _takeawayController;
  late final TextEditingController _onlineController;

  late String _selectedCategoryId;
  bool _isActive = true;
  bool _isInStock = true;
  final Set<MenuBadge> _badges = <MenuBadge>{};

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _basePriceController = TextEditingController(text: existing?.basePrice.toStringAsFixed(0) ?? '');
    _discountPriceController = TextEditingController(
      text: existing?.discountedPrice?.toStringAsFixed(0) ?? '',
    );
    _imageUrlController = TextEditingController(text: existing?.imageUrl ?? '');
    _remainingController = TextEditingController(text: '${existing?.remainingPortions ?? 10}');
    _variantsController = TextEditingController(
      text: existing == null
          ? 'Regular:0,Jumbo:5000'
          : existing.variants.map((v) => '${v.name}:${v.priceDelta.toStringAsFixed(0)}').join(','),
    );
    _addonsController = TextEditingController(
      text: existing == null
          ? 'Ekstra Telur:4000,Ekstra Daging:7000'
          : existing.addOns.map((a) => '${a.name}:${a.price.toStringAsFixed(0)}').join(','),
    );
    _customNotesController = TextEditingController(
      text: existing == null ? 'Pedas,Sedang,Tidak Pedas' : existing.customNotes.join(','),
    );
    _dineInController = TextEditingController(
      text: existing?.channelPricing.dineIn.toStringAsFixed(0) ?? '',
    );
    _takeawayController = TextEditingController(
      text: existing?.channelPricing.takeaway.toStringAsFixed(0) ?? '',
    );
    _onlineController = TextEditingController(
      text: existing?.channelPricing.online.toStringAsFixed(0) ?? '',
    );

    _selectedCategoryId = existing?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'uncategorized');
    _isActive = existing?.isActive ?? true;
    _isInStock = existing?.isInStock ?? true;
    _badges.addAll(existing?.badges ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _discountPriceController.dispose();
    _imageUrlController.dispose();
    _remainingController.dispose();
    _variantsController.dispose();
    _addonsController.dispose();
    _customNotesController.dispose();
    _dineInController.dispose();
    _takeawayController.dispose();
    _onlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Tambah Menu Baru' : 'Edit Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.space2),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _field(_nameController, 'Nama Item'),
                    _field(_descriptionController, 'Deskripsi', maxLines: 2),
                    _field(_basePriceController, 'Harga Dasar'),
                    _field(_discountPriceController, 'Harga Coret (opsional)'),
                    _field(_imageUrlController, 'URL Foto Produk (rasio 1:1 disarankan)'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: widget.categories
                          .map((category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    _field(_variantsController, 'Varian (format: Nama:HargaDelta,...)'),
                    _field(_addonsController, 'Add-ons (format: Nama:Harga,...)'),
                    _field(_customNotesController, 'Custom Notes (pisahkan koma)'),
                    const SizedBox(height: AppSpacing.space2),
                    _field(_remainingController, 'Sisa Porsi'),
                    _field(_dineInController, 'Harga Dine-in'),
                    _field(_takeawayController, 'Harga Takeaway'),
                    _field(_onlineController, 'Harga Online'),
                    const SizedBox(height: AppSpacing.space2),
                    Wrap(
                      spacing: AppSpacing.space2,
                      children: MenuBadge.values
                          .map(
                            (badge) => FilterChip(
                              label: Text(badge.label),
                              selected: _badges.contains(badge),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _badges.add(badge);
                                  } else {
                                    _badges.remove(badge);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aktif'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In Stock'),
                      value: _isInStock,
                      onChanged: (value) => setState(() => _isInStock = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty || _basePriceController.text.trim().isEmpty) {
      return;
    }

    final basePrice = double.tryParse(_basePriceController.text.trim()) ?? 0;
    final discountText = _discountPriceController.text.trim();
    final discount = discountText.isEmpty ? null : double.tryParse(discountText);
    final remainingPortions = int.tryParse(_remainingController.text.trim()) ?? 0;

    final result = _MenuFormResult(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
      basePrice: basePrice,
      discountedPrice: discount,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=800'
          : _imageUrlController.text.trim(),
      variants: _parseVariants(_variantsController.text),
      addOns: _parseAddOns(_addonsController.text),
      customNotes: _parseNotes(_customNotesController.text),
      badges: _badges.toList(),
      isActive: _isActive,
      isInStock: _isInStock,
      remainingPortions: remainingPortions,
      channelPricing: MenuChannelPricing(
        dineIn: double.tryParse(_dineInController.text.trim()) ?? basePrice,
        takeaway: double.tryParse(_takeawayController.text.trim()) ?? basePrice,
        online: double.tryParse(_onlineController.text.trim()) ?? basePrice,
      ),
    );

    Navigator.of(context).pop(result);
  }

  List<MenuVariantOption> _parseVariants(String raw) {
    return raw
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map((entry) {
          final parts = entry.split(':');
          final name = parts.first.trim();
          final delta =
              parts.length > 1 ? (double.tryParse(parts[1].trim()) ?? 0.0) : 0.0;
          return MenuVariantOption(name: name, priceDelta: delta);
        })
        .toList();
  }

  List<MenuAddOnOption> _parseAddOns(String raw) {
    return raw
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map((entry) {
          final parts = entry.split(':');
          final name = parts.first.trim();
          final price =
              parts.length > 1 ? (double.tryParse(parts[1].trim()) ?? 0.0) : 0.0;
          return MenuAddOnOption(name: name, price: price);
        })
        .toList();
  }

  List<String> _parseNotes(String raw) {
    return raw
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
}

class _MenuFormResult {
  const _MenuFormResult({
    required this.name,
    required this.description,
    required this.categoryId,
    required this.basePrice,
    required this.discountedPrice,
    required this.channelPricing,
    required this.imageUrl,
    required this.variants,
    required this.addOns,
    required this.customNotes,
    required this.badges,
    required this.isActive,
    required this.isInStock,
    required this.remainingPortions,
  });

  final String name;
  final String description;
  final String categoryId;
  final double basePrice;
  final double? discountedPrice;
  final MenuChannelPricing channelPricing;
  final String imageUrl;
  final List<MenuVariantOption> variants;
  final List<MenuAddOnOption> addOns;
  final List<String> customNotes;
  final List<MenuBadge> badges;
  final bool isActive;
  final bool isInStock;
  final int remainingPortions;

  MenuManagementItemEntity toEntity({required String id, int sortOrder = 0}) {
    return MenuManagementItemEntity(
      id: id,
      name: name,
      description: description,
      categoryId: categoryId,
      basePrice: basePrice,
      discountedPrice: discountedPrice,
      channelPricing: channelPricing,
      imageUrl: imageUrl,
      imageAspectRatio: 1,
      variants: variants,
      addOns: addOns,
      customNotes: customNotes,
      badges: badges,
      isActive: isActive,
      isInStock: isInStock,
      remainingPortions: remainingPortions,
      sortOrder: sortOrder,
    );
  }
}
