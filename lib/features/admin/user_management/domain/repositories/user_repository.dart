import 'package:fe_gangsta_flutter/features/admin/user_management/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
}
