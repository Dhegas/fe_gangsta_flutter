import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_entity.dart';

class TenantListState {
  const TenantListState({
    this.isLoading = false,
    this.tenants = const [],
    this.searchQuery = '',
    this.filterStatus = 'all',
    this.page = 1,
    this.limit = 10,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final bool isLoading;
  final List<TenantEntity> tenants;
  final String searchQuery;
  final String filterStatus;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  TenantListState copyWith({
    bool? isLoading,
    List<TenantEntity>? tenants,
    String? searchQuery,
    String? filterStatus,
    int? page,
    int? limit,
    int? totalItems,
    int? totalPages,
  }) {
    return TenantListState(
      isLoading: isLoading ?? this.isLoading,
      tenants: tenants ?? this.tenants,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
