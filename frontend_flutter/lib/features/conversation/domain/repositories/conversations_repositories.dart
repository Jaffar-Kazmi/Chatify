import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationRepository {
  Future<List<ConversationEntity>> fetchConversations();

  Future<String> checkOrCreateConversation({required String contactId});

  Future<void> markConversationAsRead(String conversationId);

}