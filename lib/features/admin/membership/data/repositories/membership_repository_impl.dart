import 'package:fe_gangsta_flutter/features/admin/membership/data/datasources/membership_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/domain/entities/membership_entity.dart';
import 'package:fe_gangsta_flutter/features/admin/membership/domain/repositories/membership_repository.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  MembershipRepositoryImpl(this._localDataSource);

  final MembershipLocalDataSource _localDataSource;

  @override
  Future<List<MembershipEntity>> getMemberships() async {
    return await _localDataSource.getMemberships();
  }
}
