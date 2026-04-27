import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String messageId;
  final String roomId;
  final String senderId;
  final String senderUsername;
  final String text;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.senderUsername,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [messageId];
}
