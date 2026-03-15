import 'package:picverse/features/search/domain/repositories/search_repository.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final FirestoreService _firestoreService;

  SearchRepositoryImpl({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  @override
  Future<List<UserModel>> searchUsers(String query) {
    return _firestoreService.searchUsers(query);
  }
}
