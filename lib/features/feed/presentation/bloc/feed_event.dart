import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {}

class FeedRefreshRequested extends FeedEvent {}

class FeedPostLikeToggled extends FeedEvent {
  final String postId;
  final bool isLiked;

  const FeedPostLikeToggled({required this.postId, required this.isLiked});

  @override
  List<Object?> get props => [postId, isLiked];
}

class FeedConnectivityChanged extends FeedEvent {
  final bool isOnline;

  const FeedConnectivityChanged({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}
