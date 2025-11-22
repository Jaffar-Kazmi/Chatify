import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';

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

  void _showInputValues() {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    print('Username: $username');
    print('Email: $email');
    print('Password: $password');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  icon: Icons.password,
                  controller: _passwordController),
              SizedBox(height: 20,),
              AuthButton(
                  text: 'Register',
                  onPressed: () {}
              ),
              SizedBox(height: 20,),
              LoginPrompt(
                  title: 'Already have an account? ',
                  subTitle: 'Login',
                  onTap: () {}
              ),
            ],
          ),
        ),
      ),
    );
  }
}