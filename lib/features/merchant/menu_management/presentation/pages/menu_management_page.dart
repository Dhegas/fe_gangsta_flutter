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
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  late final MenuManagementController _controller;

  @override
  void initState() {
    super.initState();

    final repository = MenuManagementRepositoryImpl(
      MenuManagementLocalDataSource(),
    );

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: MerchantSidebar(
                    merchantName: state.merchantName,
                    merchantRoleLabel: state.merchantRoleLabel,
                    selectedItem: MerchantNavItem.menuManagement,
                    onTapItem: _handleSidebarTap,
                  ),
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
                              if (!isDesktop)
                                Builder(
                                  builder: (context) {
                                    return IconButton(
                                      onPressed: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                      icon: const Icon(Icons.menu_rounded),
                                    );
                                  },
                                ),
                              MerchantTopBar(
                                onSearchChanged: _controller.updateSearch,
                                isCompact: !isDesktop,
                              ),
                              const SizedBox(height: AppSpacing.space6),
                              _HeaderSection(
                                onAddTap: () {
                                  _showFeatureToast();
                                },
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              MenuManagementCategoryTabs(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onSelected: _controller.updateCategory,
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              Expanded(
                                child: _MenuGrid(
                                  items: _controller.filteredItems,
                                  categories: state.categories,
                                  onToggleStock: _controller.toggleStock,
                                  onAddCardTap: _showFeatureToast,
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

  void _showFeatureToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini siap dihubungkan ke flow create/edit menu.'),
      ),
    );
  }

  void _handleSidebarTap(MerchantNavItem item) {
    navigateToMerchantSection(
      context,
      item,
      MerchantNavItem.menuManagement,
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      runSpacing: AppSpacing.space4,
      spacing: AppSpacing.space4,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Management',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Update your seasonal dishes, pricing, and stock levels.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFAB3500), AppColors.primary],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33AB3500),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space5,
                vertical: AppSpacing.space3,
              ),
            ),
          ),
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
    required this.onAddCardTap,
  });

  final List<MenuManagementItemEntity> items;
  final List<MenuManagementCategory> categories;
  final void Function(String itemId, bool isInStock) onToggleStock;
  final VoidCallback onAddCardTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1320
            ? 5
            : width >= 1120
            ? 4
            : width >= 760
            ? 3
            : width >= 520
            ? 2
            : 1;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.space4,
            mainAxisSpacing: AppSpacing.space4,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return AddNewProductCard(onTap: onAddCardTap);
            }

            final item = items[index];
            final categoryLabel = categories
                .firstWhere((category) => category.id == item.categoryId)
                .label;

            return MerchantMenuItemCard(
              item: item,
              categoryLabel: categoryLabel,
              onToggleStock: (isInStock) {
                onToggleStock(item.id, isInStock);
              },
            );
          },
        );
      },
    );
  }
}
