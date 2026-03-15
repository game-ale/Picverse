import 'package:equatable/equatable.dart';

import 'package:picverse/features/auth/data/models/user_model.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<UserModel> results;
  final String query;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.query = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    List<UserModel>? results,
    String? query,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [status, results, query];
}
