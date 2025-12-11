

import 'package:chat_app/features/conversation/data/datasources/coversation_remote_data_source.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversations_repositories.dart';

import '../../domain/entities/conversation_entity.dart';

class ConversationRepositoryImplementation implements ConversationRepository {
  final ConversationsRemoteDataSource conversationsRemoteDataSource;

  ConversationRepositoryImplementation({required this.conversationsRemoteDataSource});

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    return await conversationsRemoteDataSource.fetchConversations();
  }

  @override
  Future<String> checkOrCreateConversation({required String contactId}) async {
    return await conversationsRemoteDataSource.checkOrCreateConversation(contactId: contactId);
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    return await conversationsRemoteDataSource.markConversationAsRead(conversationId);
  }
}