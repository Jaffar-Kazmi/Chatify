import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

import '../datasources/messages_remote_data_sources.dart';

class MessageRepositoryImplementation implements MessagesRepository {
  final MessageRemoteDataSource messageRemoteDataSource;

  MessageRepositoryImplementation({required this.messageRemoteDataSource});


  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    return await messageRemoteDataSource.fetchMessages(conversationId);

  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId) async {
    return await messageRemoteDataSource.fetchDailyQuestion(conversationId);
  }
  
}