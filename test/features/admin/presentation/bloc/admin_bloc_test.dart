import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockAdminRepository mockAdminRepo;
  late AdminBloc adminBloc;

  final tStats = {'users': 100, 'posts': 500, 'reports': 5};
  final tUsers = [createTestUser(), createTestUser(userId: 'u2')];
  final tPosts = [createTestPost(), createTestPost(postId: 'p2')];
  final tReports = [createTestReport()];

  setUp(() {
    mockAdminRepo = MockAdminRepository();
    adminBloc = AdminBloc(adminRepository: mockAdminRepo);
  });

  tearDown(() => adminBloc.close());

  group('AdminBloc', () {
    test('initial state is correct', () {
      expect(adminBloc.state, const AdminState());
      expect(adminBloc.state.status, AdminStatus.initial);
    });

    group('AdminLoadDashboard', () {
      blocTest<AdminBloc, AdminState>(
        'emits [loading, loaded] with stats and reports',
        setUp: () {
          when(() => mockAdminRepo.getStats()).thenAnswer((_) async => tStats);
          when(
            () => mockAdminRepo.getPendingReports(),
          ).thenAnswer((_) async => tReports);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadDashboard()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          AdminState(
            status: AdminStatus.loaded,
            stats: tStats,
            reports: tReports,
          ),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(() => mockAdminRepo.getStats()).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadDashboard()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          isA<AdminState>().having(
            (s) => s.status,
            'status',
            AdminStatus.error,
          ),
        ],
      );
    });

    group('AdminLoadUsers', () {
      blocTest<AdminBloc, AdminState>(
        'emits [loading, loaded] with users',
        setUp: () {
          when(
            () => mockAdminRepo.getAllUsers(),
          ).thenAnswer((_) async => tUsers);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadUsers()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          AdminState(status: AdminStatus.loaded, users: tUsers),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(() => mockAdminRepo.getAllUsers()).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadUsers()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          isA<AdminState>().having(
            (s) => s.status,
            'status',
            AdminStatus.error,
          ),
        ],
      );
    });

    group('AdminLoadPosts', () {
      blocTest<AdminBloc, AdminState>(
        'emits [loading, loaded] with posts',
        setUp: () {
          when(
            () => mockAdminRepo.getAllPosts(),
          ).thenAnswer((_) async => tPosts);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadPosts()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          AdminState(status: AdminStatus.loaded, posts: tPosts),
        ],
      );
    });

    group('AdminLoadReports', () {
      blocTest<AdminBloc, AdminState>(
        'emits [loading, loaded] with reports',
        setUp: () {
          when(
            () => mockAdminRepo.getPendingReports(),
          ).thenAnswer((_) async => tReports);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(AdminLoadReports()),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          AdminState(status: AdminStatus.loaded, reports: tReports),
        ],
      );
    });

    group('AdminBanUser', () {
      blocTest<AdminBloc, AdminState>(
        'bans user and reloads users',
        setUp: () {
          when(() => mockAdminRepo.banUser('u2')).thenAnswer((_) async {});
          when(
            () => mockAdminRepo.getAllUsers(),
          ).thenAnswer((_) async => tUsers);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminBanUser('u2')),
        expect: () => [
          // AdminLoadUsers dispatches: loading + loaded
          const AdminState(status: AdminStatus.loading),
          AdminState(status: AdminStatus.loaded, users: tUsers),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits error on ban failure',
        setUp: () {
          when(() => mockAdminRepo.banUser('u2')).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminBanUser('u2')),
        expect: () => [
          isA<AdminState>().having(
            (s) => s.errorMessage,
            'msg',
            'Failed to ban user',
          ),
        ],
      );
    });

    group('AdminUnbanUser', () {
      blocTest<AdminBloc, AdminState>(
        'unbans user and reloads users',
        setUp: () {
          when(() => mockAdminRepo.unbanUser('u2')).thenAnswer((_) async {});
          when(
            () => mockAdminRepo.getAllUsers(),
          ).thenAnswer((_) async => tUsers);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminUnbanUser('u2')),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          AdminState(status: AdminStatus.loaded, users: tUsers),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits error on unban failure',
        setUp: () {
          when(
            () => mockAdminRepo.unbanUser('u2'),
          ).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminUnbanUser('u2')),
        expect: () => [
          isA<AdminState>().having(
            (s) => s.errorMessage,
            'msg',
            'Failed to unban user',
          ),
        ],
      );
    });

    group('AdminDeletePost', () {
      blocTest<AdminBloc, AdminState>(
        'deletes post and reloads posts',
        setUp: () {
          when(() => mockAdminRepo.deletePost('p1')).thenAnswer((_) async {});
          when(() => mockAdminRepo.getAllPosts()).thenAnswer((_) async => []);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminDeletePost('p1')),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          const AdminState(status: AdminStatus.loaded, posts: []),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits error on delete failure',
        setUp: () {
          when(
            () => mockAdminRepo.deletePost('p1'),
          ).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminDeletePost('p1')),
        expect: () => [
          isA<AdminState>().having(
            (s) => s.errorMessage,
            'msg',
            'Failed to delete post',
          ),
        ],
      );
    });

    group('AdminResolveReport', () {
      blocTest<AdminBloc, AdminState>(
        'resolves report and reloads reports',
        setUp: () {
          when(
            () => mockAdminRepo.resolveReport('r1'),
          ).thenAnswer((_) async {});
          when(
            () => mockAdminRepo.getPendingReports(),
          ).thenAnswer((_) async => []);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminResolveReport('r1')),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          const AdminState(status: AdminStatus.loaded, reports: []),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits error on resolve failure',
        setUp: () {
          when(
            () => mockAdminRepo.resolveReport('r1'),
          ).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminResolveReport('r1')),
        expect: () => [
          isA<AdminState>().having(
            (s) => s.errorMessage,
            'msg',
            'Failed to resolve report',
          ),
        ],
      );
    });

    group('AdminDismissReport', () {
      blocTest<AdminBloc, AdminState>(
        'dismisses report and reloads reports',
        setUp: () {
          when(
            () => mockAdminRepo.dismissReport('r1'),
          ).thenAnswer((_) async {});
          when(
            () => mockAdminRepo.getPendingReports(),
          ).thenAnswer((_) async => []);
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminDismissReport('r1')),
        expect: () => [
          const AdminState(status: AdminStatus.loading),
          const AdminState(status: AdminStatus.loaded, reports: []),
        ],
      );

      blocTest<AdminBloc, AdminState>(
        'emits error on dismiss failure',
        setUp: () {
          when(
            () => mockAdminRepo.dismissReport('r1'),
          ).thenThrow(Exception('fail'));
        },
        build: () => adminBloc,
        act: (bloc) => bloc.add(const AdminDismissReport('r1')),
        expect: () => [
          isA<AdminState>().having(
            (s) => s.errorMessage,
            'msg',
            'Failed to dismiss report',
          ),
        ],
      );
    });
  });
}
