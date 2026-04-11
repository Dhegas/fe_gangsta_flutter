import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    required super.id,
    required super.name,
    required super.price,
    required super.billingCycle,
    required super.features,
    required super.isPopular,
  });
}
