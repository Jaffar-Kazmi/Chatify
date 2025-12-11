import 'dart:convert';

import 'package:chat_app/core/constants.dart';
import 'package:chat_app/features/conversation/data/models/coversation_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ConversationsRemoteDataSource {
  final _storage = FlutterSecureStorage();

  Future<List<ConversationModel>> fetchConversations() async {
   String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/conversations'),
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

  Future<String> checkOrCreateConversation({required String contactId}) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/conversations/check-or-create'),
      body: jsonEncode({'contactId': contactId, }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['conversationId'];
    } else {
      throw Exception('Failed to check or create conversation.');
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    final token = await _storage.read(key: 'token') ?? '';
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/conversations/$conversationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Mark read status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read: ${response.body}');
    }
  }
}