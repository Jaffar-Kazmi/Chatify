abstract class ConversationEvent {

}

class FetchConversations extends ConversationEvent {
  
}

class UpdateLastMessageEvent extends ConversationEvent {
  final String conversationId;
  final String lastMessage;
  final DateTime lastMessageTime;

  UpdateLastMessageEvent({
    required this.conversationId,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}