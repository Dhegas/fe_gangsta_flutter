import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';

class MembershipListState {
  const MembershipListState({
    this.isLoading = false,
    this.memberships = const [],
  });

  final bool isLoading;
  final List<MembershipEntity> memberships;

  MembershipListState copyWith({
    bool? isLoading,
    List<MembershipEntity>? memberships,
  }) {
    return MembershipListState(
      isLoading: isLoading ?? this.isLoading,
      memberships: memberships ?? this.memberships,
    );
  }
}
