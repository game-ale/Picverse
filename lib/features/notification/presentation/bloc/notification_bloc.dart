import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/notification/data/models/notification_model.dart';
import 'package:picverse/features/notification/domain/repositories/notification_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_event.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  final AuthService _authService;
  StreamSubscription<List<NotificationModel>>? _notificationsSub;

  NotificationBloc({
    required NotificationRepository notificationRepository,
    required AuthService authService,
  }) : _notificationRepository = notificationRepository,
       _authService = authService,
       super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<_NotificationStreamUpdated>(_onStreamUpdated);
    on<_NotificationStreamFailed>(_onStreamFailed);
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
          errorMessage: null,
        ),
      );

      try {
        await _notificationsSub?.cancel();
        _notificationsSub = _notificationRepository.watchNotifications(uid).listen(
          (notifications) {
            add(_NotificationStreamUpdated(notifications));
          },
          onError: (_) {
            add(_NotificationStreamFailed());
          },
        );
      } catch (_) {
        // Keep the initial load working even if live updates are unavailable.
      }
    } catch (_) {
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
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _authService.currentUser!.uid;
    await _notificationRepository.markAllAsRead(uid);
  }

  void _onStreamUpdated(
    _NotificationStreamUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: NotificationStatus.loaded,
        notifications: event.notifications,
        errorMessage: null,
      ),
    );
  }

  void _onStreamFailed(
    _NotificationStreamFailed event,
    Emitter<NotificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to load notifications',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationsSub?.cancel();
    return super.close();
  }
}

class _NotificationStreamUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;

  const _NotificationStreamUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class _NotificationStreamFailed extends NotificationEvent {}
