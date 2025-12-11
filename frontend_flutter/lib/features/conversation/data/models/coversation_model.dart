import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required id,
    required participantName,
    String? profileImageUrl,
    required lastMessage,
    required lastMessageTime,
    required unreadCount,
  }): super (
    id: id,
    participantName: participantName,
      profileImageUrl: profileImageUrl,
    lastMessage: lastMessage,
    lastMessageTime: lastMessageTime,
    unreadCount: unreadCount,
  );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    int unread = 0;
    final rawUnread = json['unread_count'];
    if (rawUnread is int) {
      unread = rawUnread;
    } else if (rawUnread is String) {
      unread = int.tryParse(rawUnread) ?? 0;
    }

    return ConversationModel(
      id: json['conversation_id'],
      participantName: json['participant_name'],
      profileImageUrl: json['participant_profile_image'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: unread,
    );
  }
}