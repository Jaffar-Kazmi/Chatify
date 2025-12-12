import 'package:flutter/cupertino.dart';

class ContactEntity {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;

  ContactEntity({required this.id, required this.username, required this.email, this.profileImageUrl});

}