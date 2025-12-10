import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/core/constants.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final _storage = FlutterSecureStorage();

  Future<ProfileModel> getProfile() async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/profile'),
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
      Uri.parse('${AppConstants.baseUrl}/profile'),
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
    var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}/profile/upload'));
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

  Future<String?> getProfileImageUrl() async {
    final token = await _storage.read(key: 'token') ?? '';

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final profileImageUrl = data['profile_image'] ?? null;

      if (profileImageUrl != null) {
        await _storage.write(key: 'profileImageUrl', value: profileImageUrl);
        return profileImageUrl;
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch profile image');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  final url = Uri.parse('${AppConstants.baseUrl}/auth/change-password');

  final response = await http.put(
  url,
  headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
  'currentPassword': currentPassword,
  'newPassword': newPassword,
  }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode != 200) {
  // Parse error from backend
  try {
  final errorData = jsonDecode(response.body);
  throw Exception(errorData['message'] ?? errorData['error'] ?? 'Unknown error');
  } catch (e) {
  // If JSON parsing fails, throw raw body
  throw Exception('Server error: ${response.body}');
  }
  }
  }
}
