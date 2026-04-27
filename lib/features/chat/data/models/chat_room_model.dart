import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picverse/features/chat/domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.roomId,
    required super.participantIds,
    required super.participantUsernames,
    required super.participantProfileImages,
    required super.isGroup,
    required super.createdBy,
    super.groupName,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCounts,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatRoomModel(
      roomId: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      participantUsernames: List<String>.from(data['participantUsernames'] ?? const []),
      participantProfileImages: List<String>.from(data['participantProfileImages'] ?? const []),
      isGroup: data['isGroup'] as bool? ?? false,
      groupName: data['groupName'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCounts: _mapCounts(data['unreadCounts']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantUsernames': participantUsernames,
      'participantProfileImages': participantProfileImages,
      'isGroup': isGroup,
      'groupName': groupName,
      'createdBy': createdBy,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static Map<String, int> _mapCounts(dynamic raw) {
    if (raw is! Map<String, dynamic>) return const {};
    return raw.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0));
  }

  static String directRoomId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }

  static Map<String, dynamic> createDirectPayload({
    required String currentUserId,
    required String currentUsername,
    required String currentPhotoUrl,
    required String otherUserId,
    required String otherUsername,
    required String otherPhotoUrl,
  }) {
    return {
      'participantIds': [currentUserId, otherUserId],
      'participantUsernames': [currentUsername, otherUsername],
      'participantProfileImages': [currentPhotoUrl, otherPhotoUrl],
      'isGroup': false,
      'groupName': null,
      'createdBy': currentUserId,
      'lastMessage': null,
      'lastMessageAt': null,
      'unreadCounts': {currentUserId: 0, otherUserId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> createGroupPayload({
    required List<String> participantIds,
    required List<String> participantUsernames,
    required List<String> participantProfileImages,
    required String creatorId,
    required String groupName,
  }) {
    final unreadCounts = <String, int>{};
    for (final id in participantIds) {
      unreadCounts[id] = 0;
    }
    return {
      'participantIds': participantIds,
      'participantUsernames': participantUsernames,
      'participantProfileImages': participantProfileImages,
      'isGroup': true,
      'groupName': groupName,
      'createdBy': creatorId,
      'lastMessage': null,
      'lastMessageAt': null,
      'unreadCounts': unreadCounts,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
