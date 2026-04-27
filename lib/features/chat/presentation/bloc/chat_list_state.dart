import 'package:equatable/equatable.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';

enum ChatListStatus { initial, loading, loaded, error }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatRoomModel> rooms;
  final String? errorMessage;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.rooms = const [],
    this.errorMessage,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatRoomModel>? rooms,
    String? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rooms, errorMessage];
}
