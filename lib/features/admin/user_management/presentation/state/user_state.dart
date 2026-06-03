import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

class UserState {
  const UserState({
    this.users = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filterRole = 'ALL',
    this.page = 1,
    this.limit = 10,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final List<UserEntity> users;
  final bool isLoading;
  final String searchQuery;

  /// 'ALL' | 'CUSTOMER' | 'PARTNER'
  final String filterRole;

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  UserState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? searchQuery,
    String? filterRole,
    int? page,
    int? limit,
    int? totalItems,
    int? totalPages,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filterRole: filterRole ?? this.filterRole,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

