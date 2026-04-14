import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';

class BillingState {
  const BillingState({
    this.billings = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filterStatus = 'all',
  });

  final List<BillingEntity> billings;
  final bool isLoading;
  final String searchQuery;
  final String filterStatus;

  BillingState copyWith({
    List<BillingEntity>? billings,
    bool? isLoading,
    String? searchQuery,
    String? filterStatus,
  }) {
    return BillingState(
      billings: billings ?? this.billings,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}
