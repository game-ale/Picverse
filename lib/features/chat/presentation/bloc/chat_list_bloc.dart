import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_list_event.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _roomsSubscription;

  ChatListBloc(this._chatRepository) : super(const ChatListState()) {
    on<ChatListStarted>(_onStarted);
    on<_ChatListStreamUpdated>(_onStreamUpdated);
    on<_ChatListStreamFailed>(_onStreamFailed);
  }

  Future<void> _onStarted(ChatListStarted event, Emitter<ChatListState> emit) async {
    await _roomsSubscription?.cancel();
    emit(state.copyWith(status: ChatListStatus.loading, errorMessage: null));
    _roomsSubscription = _chatRepository.watchChatRooms(event.userId).listen(
          (rooms) => add(_ChatListStreamUpdated(rooms)),
          onError: (_) => add(const _ChatListStreamFailed()),
        );
  }

  void _onStreamUpdated(
    _ChatListStreamUpdated event,
    Emitter<ChatListState> emit,
  ) {
    emit(state.copyWith(status: ChatListStatus.loaded, rooms: event.rooms));
  }

  void _onStreamFailed(
    _ChatListStreamFailed event,
    Emitter<ChatListState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatListStatus.error,
        errorMessage: 'Failed to load chats',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _roomsSubscription?.cancel();
    return super.close();
  }
}

class _ChatListStreamUpdated extends ChatListEvent {
  final List<ChatRoomModel> rooms;

  const _ChatListStreamUpdated(this.rooms);
}

class _ChatListStreamFailed extends ChatListEvent {
  const _ChatListStreamFailed();
}
