import 'dart:convert';

import 'package:chat_app/features/conversation/data/models/coversation_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ConversationsRemoteDataSource {
  final String baseUrl = 'http://localhost:3000';
  final _storage = FlutterSecureStorage();

  Future<List<ConversationModel>> fetchConversations() async {
   // String token = await _storage.read(key: 'token') ?? '';
    String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjBjNTg1NjhjLTI1ZGEtNGRhZi1hNmIyLTQ3NjdkMTZhMWM0ZiIsImlhdCI6MTc2NDAxOTMyOSwiZXhwIjoxNzY0MDU1MzI5fQ.H6WBdiLMQSol8eKV9Fx9CwV4BmtXzpDAldhsa76QFtQ";
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );
    
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((dataRow) => ConversationModel.fromJson(dataRow)).toList();
    } else {
      throw Exception('Failed to fetch conversations.');

    }

  }


}