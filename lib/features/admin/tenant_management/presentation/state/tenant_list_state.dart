import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class TenantListState {
  const TenantListState({
    this.isLoading = false,
    this.tenants = const [],
    this.searchQuery = '',
    this.filterStatus = 'all',
  });

  final bool isLoading;
  final List<TenantEntity> tenants;
  final String searchQuery;
  final String filterStatus;

  TenantListState copyWith({
    bool? isLoading,
    List<TenantEntity>? tenants,
    String? searchQuery,
    String? filterStatus,
  }) {
    return TenantListState(
      isLoading: isLoading ?? this.isLoading,
      tenants: tenants ?? this.tenants,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}
