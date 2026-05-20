import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/state/tenant_list_state.dart';
import 'package:flutter/foundation.dart';

class TenantListController extends ChangeNotifier {
  TenantListController(this._repository);

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  final TenantRepository _repository;
  
  TenantListState _state = const TenantListState();
  TenantListState get state => _state;
  
  List<TenantEntity> get tenants => _state.tenants;

  List<TenantEntity> get visibleTenants {
    return _state.tenants.where((t) {
      if (_state.filterStatus != 'all' && t.status != _state.filterStatus) {
        return false;
      }
      
      if (_state.searchQuery.isNotEmpty) {
        final query = _state.searchQuery.toLowerCase();
        if (!t.name.toLowerCase().contains(query) && 
            !t.partnerName.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  Future<void> loadPage(int page) async {
    _state = _state.copyWith(isLoading: true, page: page);
    notifyListeners();

    try {
      final result = await _repository.getTenants(page: page, limit: _state.limit);
      _state = _state.copyWith(
        tenants: result.tenants,
        page: result.page,
        limit: result.limit,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
    }
    
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadPage(1);
  }
  
  Future<void> createTenant({
    required String name,
    required String description,
    required String address,
    required String phoneNumber,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.createTenant(
        name: name,
        description: description,
        address: address,
        phoneNumber: phoneNumber,
      );
      // Re-fetch listing
      final result = await _repository.getTenants();
      _state = _state.copyWith(tenants: result.tenants, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
    
    notifyListeners();
  }

  Future<void> deleteTenant(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.deleteTenant(id);
      // Re-fetch listing
      final result = await _repository.getTenants();
      _state = _state.copyWith(tenants: result.tenants, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
    
    notifyListeners();
  }
  
  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }
  
  void updateFilter(String status) {
    _state = _state.copyWith(filterStatus: status);
    notifyListeners();
  }
}
