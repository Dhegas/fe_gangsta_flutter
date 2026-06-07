import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_profile_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/pages/customer_scan_store_page.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/widgets/store_discovery_card.dart';
import 'package:fe_gangsta_flutter/features/customer/dashboard/presentation/widgets/store_qr_sheet.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_remote_datasource.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/repositories/menu_repository_impl.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/presentation/pages/customer_menu_digital_page.dart';
import 'package:flutter/material.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({
    super.key,
    this.onLoginPressed,
    this.onLogoutPressed,
  });

  final VoidCallback? onLoginPressed;
  final VoidCallback? onLogoutPressed;

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  final _repository = MenuRepositoryImpl(
    MenuLocalDataSource(),
    MenuRemoteDataSource(ApiClient()),
  );
  final ScrollController _scrollController = ScrollController();
  List<StoreEntity> _allBookings = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadStores();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.9) {
      if (!_isLoading && !_isLoadingMore && _hasMoreData) {
        _loadNextPage();
      }
    }
  }

  Future<void> _showStoreQr(StoreEntity store) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StoreQrSheet(store: store),
    );
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
      _allBookings = [];
    });
    try {
      final stores = await _repository.getStores(page: _currentPage, limit: _limit);
      setState(() {
        _allBookings = stores;
        _isLoading = false;
        if (stores.length < _limit) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar tenant: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    try {
      final newStores = await _repository.getStores(page: _currentPage, limit: _limit);
      setState(() {
        _allBookings.addAll(newStores);
        _isLoadingMore = false;
        if (newStores.length < _limit) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat halaman berikutnya: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openScanner() async {
    final storeIds = _allBookings.map((store) => store.id).toSet();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerScanStorePage(validStoreIds: storeIds),
      ),
    );
  }

  List<StoreEntity> get _visibleStores {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return _allBookings;
    }

    return _allBookings
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
          if (ApiClient.activeToken?.isNotEmpty ?? false)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomerProfilePage(
                      onLogoutPressed: widget.onLogoutPressed,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.account_circle_rounded),
              tooltip: 'Profil',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: FilledButton.icon(
                onPressed: widget.onLoginPressed,
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
                        : Column(
                            children: [
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    final isWebsite = width >= 800;
                                    final isTablet = width >= 550 && width < 800;

                                    if (isWebsite || isTablet) {
                                      final columns = isWebsite ? 4 : 2;
                                      final availableWidth = width - (AppSpacing.space4 * 2);
                                      final tileWidth = (availableWidth - ((columns - 1) * AppSpacing.space4)) / columns;
                                      
                                      // Image height in card is 110px. Non-image content takes about 190px.
                                      // Total target height is 300px.
                                      const double targetTileHeight = 300.0;
                                      final calculatedAspectRatio = (tileWidth / targetTileHeight).clamp(0.5, 2.0);

                                      return GridView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(AppSpacing.space4),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: AppSpacing.space4,
                                          mainAxisSpacing: AppSpacing.space4,
                                          childAspectRatio: calculatedAspectRatio,
                                        ),
                                        itemCount: _visibleStores.length,
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
                                      );
                                    } else {
                                      return ListView.separated(
                                        controller: _scrollController,
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
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (_isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
