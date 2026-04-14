import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/domain/repositories/user_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/user_management/presentation/state/user_state.dart';
import 'package:flutter/foundation.dart';

class UserListController extends ChangeNotifier {
  UserListController(this._repository);

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

  final UserRepository _repository;

  UserState _state = const UserState();
  UserState get state => _state;

  List<UserEntity> get visibleUsers {
    var list = _state.users;

    if (_state.filterRole != 'all') {
      list = list.where((u) => u.role == _state.filterRole).toList();
    }

    if (_state.searchQuery.isNotEmpty) {
      final q = _state.searchQuery.toLowerCase();
      list = list
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.tenantName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final users = await _repository.getUsers();
      _state = _state.copyWith(users: users, isLoading: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void updateFilter(String role) {
    _state = _state.copyWith(filterRole: role);
    notifyListeners();
  }
}
