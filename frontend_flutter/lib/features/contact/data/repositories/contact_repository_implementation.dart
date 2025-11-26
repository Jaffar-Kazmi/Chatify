import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';
import 'package:chat_app/features/contact/domain/repositories/contacts_repository.dart';

import '../datasources/contacts_remote_data_source.dart';

class ContactRepositoryImplementation implements ContactsRepository {
  final ContactsRemoteDataSource contactsRemoteDataSource;

  ContactRepositoryImplementation({required this.contactsRemoteDataSource});

  @override
  Future<void> addContact({required String email}) async {
    await contactsRemoteDataSource.addContact(email: email);
  }

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    return await contactsRemoteDataSource.fetchContacts();
  }
  
}