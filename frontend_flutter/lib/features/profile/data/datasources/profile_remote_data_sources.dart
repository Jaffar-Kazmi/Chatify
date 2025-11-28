import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final String baseUrl = 'http://localhost:3000';
  final _storage = FlutterSecureStorage();

  Future<ProfileModel> getProfile() async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<String> uploadProfilePic(File imageFile) async {
    String token = await _storage.read(key: 'token') ?? '';
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/picture'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('profilePic', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return jsonDecode(responseData)['profilePic'];
    } else {
      throw Exception('Failed to upload profile picture');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.put(
      Uri.parse('$baseUrl/profile/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Password changed successfully');
    } else {
      throw Exception('Failed to change password');
    }
  }
}
