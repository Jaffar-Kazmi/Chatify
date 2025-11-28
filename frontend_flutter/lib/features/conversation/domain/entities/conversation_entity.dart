class ConversationEntity {
  final String id;
  final String participantName;
  final String? profileImageUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ConversationEntity({
    required this.id,
    required this.participantName,
    this.profileImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}