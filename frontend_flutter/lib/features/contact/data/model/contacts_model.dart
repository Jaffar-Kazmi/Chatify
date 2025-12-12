import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required String id,
    required String username,
    required String email,
    String? profileImageUrl,
  }) : super(
      id: id,
      username: username,
      email: email,
      profileImageUrl: profileImageUrl
  );

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
        id: json['contact_id'],
        username: json['username'],
        email: json['email'],
        profileImageUrl: json['profile_image']
    );
  }
}