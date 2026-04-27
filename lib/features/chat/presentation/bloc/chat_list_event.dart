abstract class ChatListEvent {
  const ChatListEvent();
}

class ChatListStarted extends ChatListEvent {
  final String userId;

  const ChatListStarted(this.userId);
}
