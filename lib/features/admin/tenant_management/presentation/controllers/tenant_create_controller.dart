import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/entities/tenant_create_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/domain/repositories/tenant_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/tenant_management/presentation/state/tenant_create_state.dart';
import 'package:flutter/foundation.dart';

class TenantCreateController extends ChangeNotifier {
  TenantCreateController(this._repository);

  final TenantRepository _repository;
  bool _isDisposed = false;

  TenantCreateState _state = const TenantCreateState();
  TenantCreateState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  Future<void> submit(TenantCreateEntity payload) async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    try {
      await _repository.createTenant(payload);
      _state = _state.copyWith(isSubmitting: false);
    } catch (e) {
      _state = _state.copyWith(isSubmitting: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }
}
