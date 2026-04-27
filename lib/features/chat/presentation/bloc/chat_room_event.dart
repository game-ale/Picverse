abstract class ChatRoomEvent {
  const ChatRoomEvent();
}

class ChatRoomStarted extends ChatRoomEvent {
  final String roomId;

  const ChatRoomStarted(this.roomId);
}

class ChatRoomSendMessageRequested extends ChatRoomEvent {
  final String roomId;
  final String senderId;
  final String text;

  const ChatRoomSendMessageRequested({
    required this.roomId,
    required this.senderId,
    required this.text,
  });
}

class ChatRoomMarkReadRequested extends ChatRoomEvent {
  final String roomId;
  final String userId;

  const ChatRoomMarkReadRequested({
    required this.roomId,
    required this.userId,
  });
}
