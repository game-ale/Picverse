import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/search/domain/repositories/search_repository.dart';
import 'package:picverse/features/search/presentation/bloc/search_event.dart';
import 'package:picverse/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  SearchBloc({required SearchRepository searchRepository})
    : _searchRepository = searchRepository,
      super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, query: event.query));
    try {
      final results = await _searchRepository.searchUsers(event.query.trim());
      emit(state.copyWith(status: SearchStatus.loaded, results: results));
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.error));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }
}
