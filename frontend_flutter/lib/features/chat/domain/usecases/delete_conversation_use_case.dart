import 'package:chat_app/features/chat/data/repositories/message_repository_implementation.dart';
import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class DeleteConversationUseCase {
  final MessagesRepository messagesRepository;

  DeleteConversationUseCase({required this.messagesRepository});

  Future<void> call(String conversationId) {
    return messagesRepository.deleteConversation(conversationId);
  }
}
