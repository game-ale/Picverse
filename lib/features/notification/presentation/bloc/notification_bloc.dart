import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/notification/domain/repositories/notification_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_event.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  final AuthService _authService;

  NotificationBloc({
    required NotificationRepository notificationRepository,
    required AuthService authService,
  }) : _notificationRepository = notificationRepository,
       _authService = authService,
       super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final uid = _authService.currentUser!.uid;
      final notifications = await _notificationRepository.getNotifications(uid);
      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Failed to load notifications',
        ),
      );
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationRepository.markAsRead(event.notificationId);
    add(NotificationLoadRequested());
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _authService.currentUser!.uid;
    await _notificationRepository.markAllAsRead(uid);
    add(NotificationLoadRequested());
  }
}
