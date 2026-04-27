import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_event.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_state.dart';

import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockNotificationRepository mockNotifRepo;
  late MockAuthService mockAuthService;
  late MockUser mockUser;
  late NotificationBloc notifBloc;

  final tNotifs = [
    createTestNotification(),
    createTestNotification(notificationId: 'notif2', isRead: true),
  ];

  setUp(() {
    mockNotifRepo = MockNotificationRepository();
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user1');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);

    notifBloc = NotificationBloc(
      notificationRepository: mockNotifRepo,
      authService: mockAuthService,
    );
  });

  tearDown(() => notifBloc.close());

  group('NotificationBloc', () {
    test('initial state is correct', () {
      expect(notifBloc.state, const NotificationState());
      expect(notifBloc.state.status, NotificationStatus.initial);
    });

    group('NotificationLoadRequested', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [loading, loaded] with notifications',
        setUp: () {
          when(
            () => mockNotifRepo.getNotifications('user1'),
          ).thenAnswer((_) async => tNotifs);
        },
        build: () => notifBloc,
        act: (bloc) => bloc.add(NotificationLoadRequested()),
        expect: () => [
          const NotificationState(status: NotificationStatus.loading),
          NotificationState(
            status: NotificationStatus.loaded,
            notifications: tNotifs,
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockNotifRepo.getNotifications('user1'),
          ).thenThrow(Exception('fail'));
        },
        build: () => notifBloc,
        act: (bloc) => bloc.add(NotificationLoadRequested()),
        expect: () => [
          const NotificationState(status: NotificationStatus.loading),
          const NotificationState(
            status: NotificationStatus.error,
            errorMessage: 'Failed to load notifications',
          ),
        ],
      );
    });

    group('NotificationMarkReadRequested', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks notification as read without reloading',
        setUp: () {
          when(
            () => mockNotifRepo.markAsRead('notif1'),
          ).thenAnswer((_) async {});
        },
        build: () => notifBloc,
        act: (bloc) => bloc.add(
          const NotificationMarkReadRequested(notificationId: 'notif1'),
        ),
        expect: () => [],
      );
    });

    group('NotificationMarkAllReadRequested', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks all as read without reloading',
        setUp: () {
          when(
            () => mockNotifRepo.markAllAsRead('user1'),
          ).thenAnswer((_) async {});
        },
        build: () => notifBloc,
        act: (bloc) => bloc.add(NotificationMarkAllReadRequested()),
        expect: () => [],
      );
    });
  });
}
