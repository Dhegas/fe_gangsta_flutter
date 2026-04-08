import 'package:fe_gangsta_flutter/features/admin/membership/domain/repositories/membership_repository.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/presentation/state/membership_list_state.dart';
import 'package:flutter/foundation.dart';

class MembershipListController extends ChangeNotifier {
  MembershipListController(this._repository);

  final MembershipRepository _repository;

  MembershipListState _state = const MembershipListState();
  MembershipListState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final memberships = await _repository.getMemberships();
      _state = _state.copyWith(memberships: memberships, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }
}
