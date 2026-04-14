import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

class UserState {
  const UserState({
    this.users = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filterRole = 'all',
  });

  final List<UserEntity> users;
  final bool isLoading;
  final String searchQuery;
  final String filterRole;

  UserState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? searchQuery,
    String? filterRole,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filterRole: filterRole ?? this.filterRole,
    );
  }
}
