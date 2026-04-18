import 'package:fe_gangsta_flutter/features/admin/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/dashboard/presentation/state/dashboard_state.dart';
import 'package:flutter/foundation.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);

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

  final DashboardRepository _repository;

  DashboardState _state = const DashboardState();
  DashboardState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final stats = await _repository.getStats();
      _state = _state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }
}
