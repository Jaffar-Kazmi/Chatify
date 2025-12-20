import 'package:chat_app/features/contact/presentation/bloc/contacts_bloc.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../bloc/contacts_event.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactsBloc>(context).add(FetchContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Contacts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: BlocListener<ContactsBloc, ContactState>(
        listener: (context, state) async {
          final contactsBloc = BlocProvider.of<ContactsBloc>(context);

          if (state is ConversationReady) {
            var res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                ChatPage(
                    conversationId: state.conversationId,
                    mate: state.contactName,
                    mateProfileImageUrl: state.contactProfileImageUrl,
                )
            )
            );
            if (res == null) {
              contactsBloc.add(FetchContacts());

            }
          }
        },
        child: BlocBuilder<ContactsBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return Center(child: CircularProgressIndicator(),);
            }
            else if (state is ContactLoaded) {
              return ListView.builder(
                itemCount: state.contacts.length,
                itemBuilder: (context, index){
                  final contact = state.contacts[index];
                  return ListTile(
                    title: Text(contact.username, style: Theme.of(context).textTheme.headlineSmall,),
                    subtitle: Text(contact.email, style: TextStyle(color: AppColors.textSecondary,),),
                    onTap: () {
                      BlocProvider.of<ContactsBloc>(context).add(CheckOrCreateConversation(contact.id, contact.username, contact.profileImageUrl));
                    },
                  );
                },
              );
            }
            else if (state is ContactError) {
              if (state.error.contains('No internet connection')) {
                return NoInternetWidget(
                  onRetry: () => BlocProvider.of<ContactsBloc>(context).add(FetchContacts()),
                );
              }
              return Center(child: Text(state.error),);
            }
            else {
              return Center(child: Text('No contacts found'),);
            }
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
       title: Text(
           'Add contact',
         style: Theme.of(context).textTheme.bodyLarge,
       ),
       content: TextField(
         controller: emailController,
         decoration: InputDecoration(
           hintText: 'Enter contact email',
           hintStyle: Theme.of(context).textTheme.bodyMedium,
           filled: true,
           contentPadding: const EdgeInsets.all(10),
           fillColor: AppColors.surfaceLight,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: AppColors.border),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: AppColors.primary, width: 1),
           ),
         )
       ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  BlocProvider.of<ContactsBloc>(context).add(AddContact(email));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.darkest,
                elevation: 3,
                padding: const EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                  'Add',
                style: Theme.of(context).textTheme.bodyMedium,
              )
          )
        ],
      )
    );
  }
}
