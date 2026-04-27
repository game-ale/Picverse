import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/features/chat/data/models/chat_message_model.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirestoreService _firestoreService;

  ChatRepositoryImpl(this._firestoreService);

  @override
  Future<String> createGroupRoom({
    required String creatorId,
    required String groupName,
    required List<String> participantIds,
  }) {
    return _firestoreService.createGroupChat(
      creatorId: creatorId,
      groupName: groupName,
      participantIds: participantIds,
    );
  }

  @override
  Future<String> getOrCreateDirectRoom({
    required String currentUserId,
    required String otherUserId,
  }) {
    return _firestoreService.getOrCreateDirectChatRoom(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );
  }

  @override
  Future<void> markRoomRead({required String roomId, required String userId}) {
    return _firestoreService.markChatRoomRead(roomId: roomId, userId: userId);
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) {
    return _firestoreService.sendChatMessage(
      roomId: roomId,
      senderId: senderId,
      text: text,
    );
  }

  @override
  Stream<ChatRoomModel?> watchChatRoom(String roomId) {
    return _firestoreService.watchChatRoom(roomId);
  }

  @override
  Stream<List<ChatRoomModel>> watchChatRooms(String userId) {
    return _firestoreService.watchChatRooms(userId);
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(String roomId) {
    return _firestoreService.watchChatMessages(roomId);
  }
}
