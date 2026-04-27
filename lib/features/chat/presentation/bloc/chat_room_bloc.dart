import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picverse/features/chat/data/models/chat_message_model.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _roomSubscription;
  StreamSubscription? _messagesSubscription;

  ChatRoomBloc(this._chatRepository) : super(const ChatRoomState()) {
    on<ChatRoomStarted>(_onStarted);
    on<ChatRoomSendMessageRequested>(_onSendMessageRequested);
    on<ChatRoomMarkReadRequested>(_onMarkReadRequested);
    on<_ChatRoomStreamUpdated>(_onStreamUpdated);
    on<_ChatRoomMessagesUpdated>(_onMessagesUpdated);
    on<_ChatRoomStreamFailed>(_onStreamFailed);
  }

  Future<void> _onStarted(ChatRoomStarted event, Emitter<ChatRoomState> emit) async {
    await _roomSubscription?.cancel();
    await _messagesSubscription?.cancel();
    emit(state.copyWith(status: ChatRoomStatus.loading, errorMessage: null));

    _roomSubscription = _chatRepository.watchChatRoom(event.roomId).listen(
          (room) => add(_ChatRoomStreamUpdated(room)),
          onError: (_) => add(const _ChatRoomStreamFailed()),
        );

    _messagesSubscription = _chatRepository.watchMessages(event.roomId).listen(
          (messages) => add(_ChatRoomMessagesUpdated(messages)),
          onError: (_) => add(const _ChatRoomStreamFailed()),
        );
  }

  void _onStreamUpdated(
    _ChatRoomStreamUpdated event,
    Emitter<ChatRoomState> emit,
  ) {
    emit(state.copyWith(status: ChatRoomStatus.loaded, room: event.room));
  }

  void _onMessagesUpdated(
    _ChatRoomMessagesUpdated event,
    Emitter<ChatRoomState> emit,
  ) {
    emit(state.copyWith(messages: event.messages));
  }

  void _onStreamFailed(
    _ChatRoomStreamFailed event,
    Emitter<ChatRoomState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatRoomStatus.error,
        errorMessage: 'Failed to load chat',
      ),
    );
  }

  Future<void> _onSendMessageRequested(
    ChatRoomSendMessageRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(state.copyWith(isSending: true, errorMessage: null));
    try {
      await _chatRepository.sendMessage(
        roomId: event.roomId,
        senderId: event.senderId,
        text: event.text,
      );
      emit(state.copyWith(isSending: false));
    } catch (error) {
      emit(state.copyWith(isSending: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onMarkReadRequested(
    ChatRoomMarkReadRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    await _chatRepository.markRoomRead(roomId: event.roomId, userId: event.userId);
  }

  @override
  Future<void> close() async {
    await _roomSubscription?.cancel();
    await _messagesSubscription?.cancel();
    return super.close();
  }
}

class _ChatRoomStreamUpdated extends ChatRoomEvent {
  final ChatRoomModel? room;

  const _ChatRoomStreamUpdated(this.room);
}

class _ChatRoomMessagesUpdated extends ChatRoomEvent {
  final List<ChatMessageModel> messages;

  const _ChatRoomMessagesUpdated(this.messages);
}

class _ChatRoomStreamFailed extends ChatRoomEvent {
  const _ChatRoomStreamFailed();
}
