import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/login_prompt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showInputValues() {
    String email = _emailController.text;
    String password = _passwordController.text;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInputField(hint: 'Email', icon: Icons.email, controller: _emailController),
              SizedBox(height: 20,),
              AuthInputField(hint: 'Password', icon: Icons.lock, controller: _passwordController, isPassword: true),
              SizedBox(height: 20,),
              BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return  AuthButton(
                        text: 'Login',
                        onPressed: _onLogin
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      print("Good");
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route)=> false);
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error))
                      );
                    }
                  }
              ),
              SizedBox(height: 20,),
              LoginPrompt(
                title: 'Don\'t have an account? ',
                subTitle: 'Register',
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
