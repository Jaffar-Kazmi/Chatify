import 'dart:convert';

import 'package:chat_app/core/constants.dart';
import 'package:chat_app/features/chat/data/models/daily_question_model.dart';
import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/message_entity.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  final _storage = FlutterSecureStorage();

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/messages/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if(response.statusCode == 200) {
      try {
        List data = jsonDecode(response.body);
        print("data");
        print(data);

        var res = data.map((dataRow) {
          print("Mapping row: $dataRow"); // Debug each row
          return MessageModel.fromJson(dataRow);
        }).toList();

        print("res");
        print(res);
        return res;
      } catch (e) {
        print("Mapping error: $e");
        rethrow; // Pass the error up
      }
    } else {
      throw Exception('Failed to fetch messages');
    }
  }


  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/conversations/$conversationId/daily-question'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );

    if(response.statusCode == 200) {
      return DailyQuestionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch daily question.');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/conversations/$conversationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
      );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation');
    }
  }
}