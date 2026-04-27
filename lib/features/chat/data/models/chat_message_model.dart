import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picverse/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.messageId,
    required super.roomId,
    required super.senderId,
    required super.senderUsername,
    required super.text,
    required super.createdAt,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModel(
      messageId: doc.id,
      roomId: data['roomId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderUsername: data['senderUsername'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
