import 'package:chat_app/chat_page.dart';
import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/message_page.dart';
import 'package:chat_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/domain/usecases/login_use_case.dart';
import 'features/auth/domain/usecases/register_use_case.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  final authRepository = AuthRepositoryImplementation(authRemoteDataSource: AuthRemoteDataSource());
  runApp(MyApp(authRepository: authRepository,));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImplementation authRepository;

  const MyApp({super.key, required this.authRepository});

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
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/chat': (context) => ChatPage(),
        },
      ),
    );
  }
}