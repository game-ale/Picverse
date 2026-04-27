import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String roomId;
  final List<String> participantIds;
  final List<String> participantUsernames;
  final List<String> participantProfileImages;
  final bool isGroup;
  final String? groupName;
  final String createdBy;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoomEntity({
    required this.roomId,
    required this.participantIds,
    required this.participantUsernames,
    required this.participantProfileImages,
    required this.isGroup,
    required this.createdBy,
    this.groupName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCounts = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  String titleFor(String currentUserId) {
    if (isGroup) {
      return groupName?.trim().isNotEmpty == true ? groupName!.trim() : 'Group chat';
    }
    final index = participantIds.indexWhere((id) => id != currentUserId);
    if (index >= 0 && index < participantUsernames.length) {
      return participantUsernames[index];
    }
    return 'Direct chat';
  }

  String avatarFor(String currentUserId) {
    if (isGroup) return '';
    final index = participantIds.indexWhere((id) => id != currentUserId);
    if (index >= 0 && index < participantProfileImages.length) {
      return participantProfileImages[index];
    }
    return '';
  }

  int unreadCountFor(String userId) => unreadCounts[userId] ?? 0;

  @override
  List<Object?> get props => [roomId];
}
