import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/search/presentation/bloc/search_bloc.dart';
import 'package:picverse/features/search/presentation/bloc/search_event.dart';
import 'package:picverse/features/search/presentation/bloc/search_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockSearchRepository mockSearchRepo;
  late SearchBloc searchBloc;

  final tUsers = [
    createTestUser(),
    createTestUser(userId: 'u2', username: 'u2'),
  ];

  setUp(() {
    mockSearchRepo = MockSearchRepository();
    searchBloc = SearchBloc(searchRepository: mockSearchRepo);
  });

  tearDown(() => searchBloc.close());

  group('SearchBloc', () {
    test('initial state is correct', () {
      expect(searchBloc.state, const SearchState());
      expect(searchBloc.state.status, SearchStatus.initial);
    });

    group('SearchQueryChanged', () {
      blocTest<SearchBloc, SearchState>(
        'emits [loading, loaded] with results on valid query',
        setUp: () {
          when(
            () => mockSearchRepo.searchUsers('test'),
          ).thenAnswer((_) async => tUsers);
        },
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged(query: 'test')),
        expect: () => [
          const SearchState(status: SearchStatus.loading, query: 'test'),
          SearchState(
            status: SearchStatus.loaded,
            results: tUsers,
            query: 'test',
          ),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'resets state on empty query',
        seed: () => SearchState(
          status: SearchStatus.loaded,
          results: tUsers,
          query: 'old',
        ),
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged(query: '')),
        expect: () => [const SearchState()],
      );

      blocTest<SearchBloc, SearchState>(
        'resets state on whitespace-only query',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged(query: '   ')),
        expect: () => [const SearchState()],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockSearchRepo.searchUsers('fail'),
          ).thenThrow(Exception('bad'));
        },
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchQueryChanged(query: 'fail')),
        expect: () => [
          const SearchState(status: SearchStatus.loading, query: 'fail'),
          isA<SearchState>().having(
            (s) => s.status,
            'status',
            SearchStatus.error,
          ),
        ],
      );
    });

    group('SearchCleared', () {
      blocTest<SearchBloc, SearchState>(
        'resets state to initial',
        seed: () => SearchState(
          status: SearchStatus.loaded,
          results: tUsers,
          query: 'test',
        ),
        build: () => searchBloc,
        act: (bloc) => bloc.add(SearchCleared()),
        expect: () => [const SearchState()],
      );
    });
  });
}
