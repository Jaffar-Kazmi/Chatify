import 'package:chat_app/features/conversation/data/repositories/conversations_repository_implementation.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversations_repositories.dart';

class MarkConversationAsReadUseCase {
  final ConversationRepository conversationsRepository;

  MarkConversationAsReadUseCase(this.conversationsRepository);

  Future<void> call(String conversationId) async {
    return await conversationsRepository.markConversationAsRead(conversationId);
  }
}