import 'package:chat_app/core/theme.dart';
import 'package:chat_app/core/widgets/profile_avatar.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../contact/presentation/pages/contacts_page.dart';
import '../../../profile/data/datasources/profile_remote_data_sources.dart';
import '../../../profile/presentation/profile_page.dart';
import '../bloc/conversations_event.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  String? _myProfileImageUrl;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversations());
    _loadMyProfileImage();
    _prefetchProfile();
  }

  Future<void> _loadMyProfileImage() async {
    final profileImageUrl = await _storage.read(key: 'profileImageUrl');
    setState(() {
      _myProfileImageUrl = profileImageUrl;
    });
  }

  final _profileDataSource = ProfileRemoteDataSource();

  Future<void> _prefetchProfile() async {
      final profile = await _profileDataSource.getProfile();
      await _loadMyProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.search)
          ),
          IconButton(
            icon: ProfileAvatar(
              radius: 25,
              profileImageUrl: _myProfileImageUrl,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.bodySmall
            ),
          ),

          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact(context, 'Ali'),
                _buildRecentContact(context, 'Jaffar'),
                _buildRecentContact(context, 'Raza'),
                _buildRecentContact(context, 'Kaleem'),
                _buildRecentContact(context, 'Zain'),
              ],
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)
                )
              ),
              child: BlocBuilder<ConversationsBloc, ConversationState>(
                builder: (context, state) {
                  if (state is ConversationLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  else if (state is ConversationLoaded) {
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder : (context, index) {
                        final conversation = state.conversations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => 
                                ChatPage(conversationId: conversation.id, mate: conversation.participantName, mateProfileImageUrl: conversation.profileImageUrl,)
                            ));
                          },
                          child: _buildMessageTile(
                            conversation.participantName,
                            conversation.lastMessage ?? 'No message',
                            conversation.lastMessageTime.toString(),
                            conversation.profileImageUrl,
                          ),
                        );
                      }
                    );
                  }
                  else if (state is ConversationError) {
                    return Center(child: Text(state.error));
                  }
                  else {
                    return Center(child: Text("No conversations found"),);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactsPage()),
            );
          },
          backgroundColor: DefaultColors.buttonColor,
          child: Icon(Icons.contacts),
      ),
    );
  }

  Widget _buildMessageTile(String name, String message, String time, String? profileImageUrl) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: ProfileAvatar(
          profileImageUrl: profileImageUrl,
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey),
      ),

    );
  }

  Widget _buildRecentContact(BuildContext context, String name) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://picsum.photos/200'),
        ),
        SizedBox(height: 5),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium,
        )
        ],
      ),
    );
  }
}
