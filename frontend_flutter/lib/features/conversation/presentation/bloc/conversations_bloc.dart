import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final SocketService _socketService = SocketService();

  ConversationsBloc({required this.fetchConversationsUseCase}) : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    try {
      _socketService.socket.on('conversationUpdated', onConversationUpdated);
    } catch (e) {
      print("Error initializing socket listeners: $e");
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
      emit(ConversationError('Failed to fetch conversations at the moment.'));
    }
  }
}