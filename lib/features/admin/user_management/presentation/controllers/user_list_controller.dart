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

  /// Users filtered locally by search query (role filter is done via API)
  List<UserEntity> get visibleUsers {
    final q = _state.searchQuery.toLowerCase();
    if (q.isEmpty) return _state.users;
    return _state.users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  /// Fetch users from backend. If filterRole != 'ALL', passes it as query param.
  Future<void> initialize() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final role = _state.filterRole == 'ALL' ? null : _state.filterRole;
      final users = await _repository.getUsers(role: role);
      _state = _state.copyWith(users: users, isLoading: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  Future<UserEntity> getUserDetail(String id) async {
    return await _repository.getUserDetail(id);
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
      await _loadUsers();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
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
      await _loadUsers();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleActive(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.toggleActive(id);
      await _loadUsers();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      await _loadUsers();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  /// Change active role filter and re-fetch from backend
  Future<void> updateFilter(String role) async {
    _state = _state.copyWith(filterRole: role, users: [], searchQuery: '');
    await _loadUsers();
  }
}
