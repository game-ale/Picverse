import 'package:picverse/features/auth/data/models/user_model.dart';

abstract class SearchRepository {
  Future<List<UserModel>> searchUsers(String query);
}
