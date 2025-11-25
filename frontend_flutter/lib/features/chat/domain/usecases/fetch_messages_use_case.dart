import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

import '../entities/message_entity.dart';

class FetchMessagesUseCase {
  final MessagesRepository messagesRepository;

  FetchMessagesUseCase({required this.messagesRepository});

  Future<List<MessageEntity>> call(String conversationId) async {
    return await messagesRepository.fetchMessages(conversationId);
  }
}