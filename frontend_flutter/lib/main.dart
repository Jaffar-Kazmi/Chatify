import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/contact/domain/usecases/add_contact_usecase.dart';
import 'package:chat_app/features/contact/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chat_app/features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chat_app/features/conversation/presentation/pages/conversations_page.dart';
import 'package:chat_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/socket_service.dart';
import 'features/auth/domain/usecases/login_use_case.dart';
import 'features/auth/domain/usecases/register_use_case.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/data/datasources/messages_remote_data_sources.dart';
import 'features/chat/data/repositories/message_repository_implementation.dart';
import 'features/chat/domain/usecases/fetch_daily_question_usecase.dart';
import 'features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'features/contact/data/datasources/contacts_remote_data_source.dart';
import 'features/contact/data/repositories/contact_repository_implementation.dart';
import 'features/contact/presentation/bloc/contacts_bloc.dart';
import 'features/conversation/data/datasources/coversation_remote_data_source.dart';
import 'features/conversation/data/repositories/conversations_repository_implementation.dart';
import 'features/conversation/presentation/bloc/conversations_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final socketService = SocketService();
  await socketService.initSocket();

  final authRepository = AuthRepositoryImplementation(authRemoteDataSource: AuthRemoteDataSource());
  final conversationsRepository = ConversationRepositoryImplementation(conversationsRemoteDataSource: ConversationsRemoteDataSource());
  final messagesRepository = MessageRepositoryImplementation(messageRemoteDataSource: MessageRemoteDataSource());
  final contactsRepository = ContactRepositoryImplementation(contactsRemoteDataSource: ContactsRemoteDataSource());

  runApp(MyApp(
      authRepository: authRepository,
      conversationsRepository: conversationsRepository,
      messagesRepository: messagesRepository,
      contactsRepository: contactsRepository
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImplementation authRepository;
  final ConversationRepositoryImplementation conversationsRepository;
  final MessageRepositoryImplementation messagesRepository;
  final ContactRepositoryImplementation contactsRepository;

  const MyApp({super.key,
    required this.authRepository,
    required this.conversationsRepository,
    required this.messagesRepository,
    required this.contactsRepository
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers : [
        BlocProvider(
            create: (_) => AuthBloc(
              registerUseCase: RegisterUseCase(repository: authRepository),
              loginUseCase: LoginUseCase(repository: authRepository),
            )
        ),
        BlocProvider(
            create: (_) => ConversationsBloc(
              fetchConversationsUseCase: FetchConversationsUseCase(conversationsRepository),
            )
        ),
        BlocProvider(
            create: (_) => ChatBloc(
              fetchMessagesUseCase: FetchMessagesUseCase(messagesRepository: messagesRepository),
              fetchDailyQuestionUseCase: FetchDailyQuestionUseCase(messagesRepository: messagesRepository),
            )
        ),
        BlocProvider(
            create: (_) => ContactsBloc(
              fetchContactsUseCase: FetchContactUseCase(contactsRepository: contactsRepository),
              addContactUseCase: AddContactUseCase(contactsRepository: contactsRepository),
                checkOrCreateConversationUseCase: CheckOrCreateConversationUseCase(conversationsRepository: conversationsRepository)
            )
        ),
      ],



      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => ConversationsPage(),
        },
      ),
    );
  }
}