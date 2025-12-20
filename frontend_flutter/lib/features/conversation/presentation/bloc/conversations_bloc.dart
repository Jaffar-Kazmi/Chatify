import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/conversation_entity.dart';
import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final SocketService _socketService = SocketService();

  ConversationsBloc({required this.fetchConversationsUseCase}) : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
    on<UpdateLastMessageEvent>(_onUpdateLastMessage);
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    try {
      _socketService.socket.on('conversationUpdated', onConversationUpdated);
    } catch (e) {
    }
  }

  void onConversationUpdated(data) {
    add(FetchConversations());
  }

  Future<void> _onFetchConversations(FetchConversations event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());

    try {
      final conversations = await fetchConversationsUseCase();
      emit(ConversationLoaded(conversations));
    } catch (error) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      emit(ConversationError(msg.isEmpty ? 'Failed to fetch conversations.' : msg));
    }
  }

  void _onUpdateLastMessage(UpdateLastMessageEvent event, Emitter<ConversationState> emit) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final updatedConversations = currentState.conversations.map((conversation) {
        if (conversation.id == event.conversationId) {
          return ConversationEntity(
            id: conversation.id,
            participantName: conversation.participantName,
            profileImageUrl: conversation.profileImageUrl,
            lastMessage: event.lastMessage,
            lastMessageTime: event.lastMessageTime,
            unreadCount: conversation.unreadCount,
          );
        }
        return conversation;
      }).toList();

      updatedConversations.sort((a, b) {
        final at = a.lastMessageTime;
        final bt = b.lastMessageTime;

        if (at == null && bt == null) return 0;  // both no messages
        if (at == null) return 1;                // a after b
        if (bt == null) return -1;               // b after a

        // both non-null: newest first
        return bt.compareTo(at);
      });


      emit(ConversationLoaded(updatedConversations));
    }
  }

}