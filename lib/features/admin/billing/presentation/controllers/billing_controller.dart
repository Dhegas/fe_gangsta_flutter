import 'package:fe_gangsta_flutter/features/admin/billing/domain/entities/billing_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/domain/repositories/billing_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/billing/presentation/state/billing_state.dart';
import 'package:flutter/foundation.dart';

class BillingController extends ChangeNotifier {
  BillingController(this._repository);

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

  final BillingRepository _repository;

  BillingState _state = const BillingState();
  BillingState get state => _state;

  List<BillingEntity> get visibleBillings {
    var list = _state.billings;

    if (_state.filterStatus != 'all') {
      list = list.where((b) => b.status == _state.filterStatus).toList();
    }

    if (_state.searchQuery.isNotEmpty) {
      final q = _state.searchQuery.toLowerCase();
      list = list
          .where((b) =>
              b.tenantName.toLowerCase().contains(q) ||
              b.invoiceNumber.toLowerCase().contains(q) ||
              b.plan.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final billings = await _repository.getBillings();
      _state = _state.copyWith(billings: billings, isLoading: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void updateFilter(String status) {
    _state = _state.copyWith(filterStatus: status);
    notifyListeners();
  }
}
