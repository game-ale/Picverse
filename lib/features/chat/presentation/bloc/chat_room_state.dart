import 'package:equatable/equatable.dart';
import 'package:picverse/features/chat/data/models/chat_message_model.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';

enum ChatRoomStatus { initial, loading, loaded, error }

class ChatRoomState extends Equatable {
  final ChatRoomStatus status;
  final ChatRoomModel? room;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final String? errorMessage;

  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.room,
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    ChatRoomModel? room,
    List<ChatMessageModel>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      room: room ?? this.room,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, room, messages, isSending, errorMessage];
}
