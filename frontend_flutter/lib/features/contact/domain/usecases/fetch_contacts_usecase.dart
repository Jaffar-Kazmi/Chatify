import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

import '../repositories/contacts_repository.dart';

class FetchContactUseCase {
  final ContactsRepository contactsRepository;

  FetchContactUseCase({required this.contactsRepository});

  Future<List<ContactEntity>> call() async {
    return await contactsRepository.fetchContacts();
  }

}