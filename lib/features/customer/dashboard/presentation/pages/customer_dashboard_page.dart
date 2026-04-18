import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_scan_store_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/widgets/store_discovery_card.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/widgets/store_qr_sheet.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/pages/customer_menu_digital_page.dart';
import 'package:flutter/material.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  final _repository = MenuRepositoryImpl(MenuLocalDataSource());
  List<StoreEntity> _stores = const [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _showStoreQr(StoreEntity store) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StoreQrSheet(store: store),
    );
  }

  Future<void> _loadStores() async {
    final stores = await _repository.getStores();
    setState(() {
      _stores = stores;
      _isLoading = false;
    });
  }

  Future<void> _openScanner() async {
    final storeIds = _stores.map((store) => store.id).toSet();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerScanStorePage(validStoreIds: storeIds),
      ),
    );
  }

  List<StoreEntity> get _visibleStores {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return _stores;
    }

    return _stores
        .where(
          (store) =>
              store.name.toLowerCase().contains(query) ||
              store.description.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Customer'),
        actions: [
          IconButton(
            onPressed: _openScanner,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space4,
                      AppSpacing.space4,
                      AppSpacing.space2,
                    ),
                    child: Text('Pilih Merchant', style: textTheme.titleLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama merchant...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Expanded(
                    child: _visibleStores.isEmpty
                        ? const Center(child: Text('Merchant tidak ditemukan.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            itemCount: _visibleStores.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.space3),
                            itemBuilder: (context, index) {
                              final store = _visibleStores[index];
                              return StoreDiscoveryCard(
                                store: store,
                                onShowQr: () => _showStoreQr(store),
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CustomerMenuDigitalPage(
                                        storeId: store.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
