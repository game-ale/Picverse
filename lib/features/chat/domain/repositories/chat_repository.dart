import 'package:picverse/features/chat/data/models/chat_message_model.dart';
import 'package:picverse/features/chat/data/models/chat_room_model.dart';

abstract class ChatRepository {
  Future<String> getOrCreateDirectRoom({
    required String currentUserId,
    required String otherUserId,
  });

  Future<String> createGroupRoom({
    required String creatorId,
    required String groupName,
    required List<String> participantIds,
  });

  Stream<List<ChatRoomModel>> watchChatRooms(String userId);
  Stream<ChatRoomModel?> watchChatRoom(String roomId);
  Stream<List<ChatMessageModel>> watchMessages(String roomId);

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  });

  Future<void> markRoomRead({
    required String roomId,
    required String userId,
  });
}
