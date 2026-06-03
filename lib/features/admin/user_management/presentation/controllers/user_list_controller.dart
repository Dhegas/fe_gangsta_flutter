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
    await loadPage(1);
  }

  Future<void> loadPage(int page) async {
    _state = _state.copyWith(isLoading: true, page: page);
    notifyListeners();

    try {
      final role = _state.filterRole == 'ALL' ? null : _state.filterRole;
      final result = await _repository.getUsers(
        role: role,
        page: page,
        limit: _state.limit,
      );
      _state = _state.copyWith(
        users: result.users,
        page: result.page,
        limit: result.limit,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        isLoading: false,
      );
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
      await loadPage(1);
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
      await loadPage(_state.page);
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
      await loadPage(_state.page);
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
      // If we are deleting the last element on a page, load the previous page if appropriate
      int pageToLoad = _state.page;
      if (_state.users.length == 1 && _state.page > 1) {
        pageToLoad = _state.page - 1;
      }
      await loadPage(pageToLoad);
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
    _state = _state.copyWith(
      filterRole: role,
      users: [],
      searchQuery: '',
      page: 1,
    );
    await loadPage(1);
  }
}
