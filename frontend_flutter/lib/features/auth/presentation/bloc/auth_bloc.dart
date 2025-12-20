import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final _storage = FlutterSecureStorage();


  AuthBloc({required this.registerUseCase, required this.loginUseCase}): super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.call(
        event.username,
        event.email,
        event.password,
      );
      emit(AuthSuccess(message: "Registration Successful"));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthFailure(error: msg.isEmpty ? 'Registration Failed' : msg));
    }
  }


    Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(event.email, event.password);
      await _storage.write(key: 'token', value: user.token);
      await _storage.write(key: 'userId', value: user.id);
      emit(AuthSuccess(message: "Login Successful"));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthFailure(error: msg.isEmpty ? 'Login Failed' : msg));
    }
  }
}