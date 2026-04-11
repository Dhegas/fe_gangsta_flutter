import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';

abstract class MembershipRepository {
  Future<List<MembershipEntity>> getMemberships();
}
