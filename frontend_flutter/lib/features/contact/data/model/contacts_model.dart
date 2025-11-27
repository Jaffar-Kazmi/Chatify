import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required String id,
    required String username,
    required String email
  }) : super(
      id: id,
      username: username,
      email: email
  );

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
        id: json['contact_id'],
        username: json['username'],
        email: json['email']
    );
  }
}