import 'dart:convert';
import 'dart:io';

import 'package:chat_app/core/constants.dart';
import 'package:chat_app/features/chat/data/models/daily_question_model.dart';
import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/socket_service.dart';
import '../../domain/entities/message_entity.dart';
import '../../presentation/bloc/chat_event.dart';
import '../../presentation/bloc/chat_state.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  final FlutterSecureStorage _storage;
  final SocketService _socketService;

  MessageRemoteDataSource({
    FlutterSecureStorage? storage,
    SocketService? socketService,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _socketService = socketService ?? SocketService();


  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/messages/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );

    if(response.statusCode == 200) {
      try {
        List data = jsonDecode(response.body);

        var res = data.map((dataRow) {
          return MessageModel.fromJson(dataRow);
        }).toList();

        return res;
      } catch (e) {
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

  Future<void> sendMessage({required String conversationId, required String content,}) async {
    final userId = await _storage.read(key: 'userId') ?? '';
    print('userId: $userId');

    final now = DateTime.now().toIso8601String();

    final newMessage = {
      'id': now,
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
      'created_at': now,
    };

    print('sendMessage payload: $newMessage');

    _socketService.socket.emit('sendMessage', newMessage);
  }

  Future<String> uploadImage(File imageFile) async {
    final token = await _storage.read(key: 'token') ?? '';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/api/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final response = await request.send();
    final responseData = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseData);
      return json['imageUrl'] as String;
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }
}