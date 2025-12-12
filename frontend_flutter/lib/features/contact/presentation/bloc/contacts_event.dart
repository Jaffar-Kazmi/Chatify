abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class CheckOrCreateConversation extends ContactsEvent {
  final String contactId;
  final String contactName;
  final String? contactProfileImageUrl;

  CheckOrCreateConversation(this.contactId, this.contactName, this.contactProfileImageUrl);
}


class AddContact extends ContactsEvent {
  final String email;

  AddContact(this.email);
}