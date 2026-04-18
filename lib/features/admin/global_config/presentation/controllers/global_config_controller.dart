import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/domain/repositories/global_config_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/global_config/presentation/state/global_config_state.dart';
import 'package:flutter/foundation.dart';

class GlobalConfigController extends ChangeNotifier {
  GlobalConfigController(this._repository);

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

  final GlobalConfigRepository _repository;

  GlobalConfigState _state = const GlobalConfigState();
  GlobalConfigState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final config = await _repository.getConfig();
      _state = _state.copyWith(config: config, isLoading: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  Future<bool> saveConfig(GlobalConfigEntity newConfig) async {
    _state = _state.copyWith(isSaving: true);
    notifyListeners();

    try {
      await _repository.updateConfig(newConfig);
      _state = _state.copyWith(config: newConfig, isSaving: false);
      notifyListeners();
      return true;
    } catch (_) {
      _state = _state.copyWith(isSaving: false);
      notifyListeners();
      return false;
    }
  }
}
