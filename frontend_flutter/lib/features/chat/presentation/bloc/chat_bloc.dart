import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:chat_app/features/conversation/domain/usecases/mark_conversation_as_read_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/socket_service.dart';
import '../../../conversation/presentation/bloc/conversations_bloc.dart';
import '../../../conversation/presentation/bloc/conversations_event.dart';
import '../../domain/usecases/delete_conversation_use_case.dart';
import '../../domain/usecases/fetch_daily_question_usecase.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final FetchDailyQuestionUseCase fetchDailyQuestionUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final MarkConversationAsReadUseCase markConversationAsReadUseCase;
  final ConversationsBloc? conversationsBloc;


  final SocketService _socketService = SocketService();
  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({required this.fetchMessagesUseCase, required this.fetchDailyQuestionUseCase, required this.deleteConversationUseCase,required this.markConversationAsReadUseCase, this.conversationsBloc}) : super(ChatLoadingState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<LoadDailyQuestionEvent>(_onLoadDailyQuestion);
    on<DeleteConversationEvent>(_onDeleteConversation);

    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    if (!_socketService.isConnected) {
      await _socketService.initSocket();
    }
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      // Ensure socket is ready
      if (!_socketService.isConnected) {
        await _socketService.initSocket();
      }

      final messages = await fetchMessagesUseCase(event.conversationId);
      _messages.clear();
      _messages.addAll(messages);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(ChatLoadedState(List.from(messages)));

      // Clean up previous listeners
      _socketService.socket.off('newMessage');

      await markConversationAsReadUseCase(event.conversationId);

      // Join conversation and listen for new messages
      _socketService.socket.emit('joinConversation', event.conversationId);
      _socketService.socket.on('newMessage', (data) {
        print("step1 - receive: $data");
        add(ReceiveMessageEvent(data));
      });
    } catch (error) {
      print('Error loading messages: $error');
      emit(ChatErrorState('Failed to load messages'));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    String userId = await _storage.read(key: 'userId') ?? '';
    print('userId: $userId');

    final newMessage = {
      'conversationId': event.conversationId,
      'senderId': userId,
      'content': event.content
    };

    _socketService.socket.emit('sendMessage', newMessage);

    }


  Future<void> _onReceiveMessage(
      ReceiveMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    print('step2 - receive event called');
    print(event.message);

    try {
      final message = MessageEntity(
        id: event.message['id'].toString(),
        conversationId: event.message['conversation_id'],
        senderId: event.message['sender_id'],
        content: event.message['content'],
        createdAt: DateTime.parse(event.message['created_at']),
      );

      _messages.add(message);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(ChatLoadedState(List.from(_messages)));

      // Update conversations list
      if (conversationsBloc != null) {
        conversationsBloc!.add(UpdateLastMessageEvent(
          conversationId: message.conversationId,
          lastMessage: message.content,
          lastMessageTime: message.createdAt,
        ));
      }

    } catch (e) {
      print('Error processing received message: $e');
      print('Message data: ${event.message}');
    }
  }

  Future<void> _onLoadDailyQuestion(LoadDailyQuestionEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoadingState());
      final dailyQuestion = await fetchDailyQuestionUseCase(event.conversationId);
      emit(ChatDailyQuestionLoadedState(dailyQuestion));
    } catch (error) {
      emit(ChatErrorState('Failed to load daily question'));
    }

  }

  Future<void> _onDeleteConversation(
      DeleteConversationEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      emit(ChatLoadingState());
      await deleteConversationUseCase(event.conversationId);
      emit(ChatLoadedState([]));
    } catch (e) {
      emit(ChatErrorState('Failed to delete conversation'));
    }
  }
}