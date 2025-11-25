import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/message_entity.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  final String baseUrl = 'http://localhost:3000';
  final _storage = FlutterSecureStorage();

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );

    if(response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((dataRow) =>MessageModel.fromJson(dataRow)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}