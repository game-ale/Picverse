import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {}

class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;
  const NotificationMarkReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllReadRequested extends NotificationEvent {}
