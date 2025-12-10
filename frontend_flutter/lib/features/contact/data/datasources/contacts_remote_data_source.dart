import 'dart:convert';

import 'package:chat_app/core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/contacts_model.dart';

class ContactsRemoteDataSource {
  final _storage = FlutterSecureStorage();

  Future<List<ContactModel>> fetchContacts() async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );


    print("Fetch contacts status: ${response.statusCode}");
    print("Fetch contacts body: ${response.body}");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<void> addContact({required String email}) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/contacts'),
        body: jsonEncode({'contactEmail': email}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add contact');
    }
  }
}