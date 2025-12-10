import 'dart:convert';

import 'package:chat_app/core/constants.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {

  Future<UserModel> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      body: jsonEncode({
        'email': email,
        'password': password
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    );
    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<UserModel> register({required String username, required String email, required String password}) async {
    final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    print(response.body);

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }
}