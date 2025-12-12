import 'package:chat_app/features/contact/domain/usecases/add_contact_usecase.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_event.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_state.dart';
import 'package:chat_app/features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_contacts_usecase.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactState> {
  final FetchContactUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;


  ContactsBloc({required this.checkOrCreateConversationUseCase, required this.fetchContactsUseCase, required this.addContactUseCase}) : super(ContactInitial()){
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContact);
    on<CheckOrCreateConversation>(_onCheckOrCreateConversation);
  }

  Future<void> _onFetchContacts(FetchContacts event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      final contacts = await fetchContactsUseCase();
      emit(ContactLoaded(contacts));
    } catch (e) {
      emit(ContactError('Failed to fetch contacts'));
    }
  }

  Future<void> _onAddContact(AddContact event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      await addContactUseCase(email: event.email);
      emit(ContactAdded());
      add(FetchContacts());
    } catch (e) {
      emit(ContactError('Failed to fetch contacts'));
    }
  }

  Future<void> _onCheckOrCreateConversation(CheckOrCreateConversation event, Emitter<ContactState> emit) async {
    try {
      emit(ContactLoading());
      final conversationId = await checkOrCreateConversationUseCase(contactId: event.contactId);
      emit(ConversationReady(conversationId: conversationId, contactName: event.contactName, contactProfileImageUrl: event.contactProfileImageUrl));
    } catch (e) {
      emit(ContactError('Failed to start conversation.'));
    }
  }

}