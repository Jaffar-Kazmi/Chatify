import 'package:chat_app/features/conversation/data/repositories/conversations_repository_implementation.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversations_repositories.dart';

class CheckOrCreateConversationUseCase {
  final ConversationRepository conversationsRepository;

  CheckOrCreateConversationUseCase({required this.conversationsRepository});

  Future<String> call({required String contactId}) async {
    return conversationsRepository.checkOrCreateConversation(contactId: contactId);
  }
}