import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_button.dart';
import '../widgets/login_prompt.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    BlocProvider.of<AuthBloc>(context).add(
        RegisterEvent(
            username: _usernameController.text.trim(),
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
              AuthInputField(hint: 'Username',
                  icon: Icons.person,
                  controller: _usernameController),
              SizedBox(height: 20,),
              AuthInputField(hint: 'Email',
                  icon: Icons.email,
                  controller: _emailController),
              SizedBox(height: 20,),
              AuthInputField(hint: 'Password',
                  icon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true),
              SizedBox(height: 20,),
              BlocConsumer<AuthBloc, AuthState> (
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return  AuthButton(
                        text: 'Register',
                        onPressed: _onRegister
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.background,),
                            SizedBox(width: 12,),
                            Text('Registration Successful',
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]
                        ),
                          backgroundColor: AppColors.primaryLight,
                          duration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(16),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Future.delayed(const Duration(milliseconds: 700), () {
                        if (!mounted) return;
                        Navigator.pushNamed(context, '/login');
                      });
                      Navigator.pushNamed(context, '/login');
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error))
                      );
                    }
                  }
              ),
              SizedBox(height: 20,),
              LoginPrompt(
                  title: 'Already have an account? ',
                  subTitle: 'Login',
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}