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

  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      final users = await _repository.getUsers();
      _state = _state.copyWith(users: users, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  Future<void> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.updateUser(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
      );
      final users = await _repository.getUsers();
      _state = _state.copyWith(users: users, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  Future<void> toggleActive(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.toggleActive(id);
      final users = await _repository.getUsers();
      _state = _state.copyWith(users: users, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      final users = await _repository.getUsers();
      _state = _state.copyWith(users: users, isLoading: false);
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

  void updateFilter(String role) {
    _state = _state.copyWith(filterRole: role);
    notifyListeners();
  }
}
