import 'package:chat_app/core/theme.dart';
import 'package:chat_app/core/widgets/profile_avatar.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

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
  final _storage = const FlutterSecureStorage();
  final _profileDataSource = ProfileRemoteDataSource();

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversations());
    _loadMyProfileImage();
    _prefetchProfile();
  }

  Future<void> _loadMyProfileImage() async {
    try {
      final profileImageUrl = await _profileDataSource.getProfileImageUrl();
      setState(() {
        _myProfileImageUrl = profileImageUrl;
      });
    } catch (e) {
      print('Failed to fetch profile image: $e');
    }
  }

  Future<void> _prefetchProfile() async {
    await _profileDataSource.getProfile();
    await _loadMyProfileImage();
  }

  String formatMessageTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return ''; // fallback if null
    }

    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();

      final isToday = dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;

      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday = dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day;

      if (isToday) {
        return DateFormat('h:mm a').format(dateTime); // e.g., 10:42 AM
      } else if (isYesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM d').format(dateTime); // e.g., Nov 29
      }
    } catch (e) {
      return ''; // fallback if parsing fails
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by username',
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        )
            : Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        titleSpacing: 15,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            iconSize: 25,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),

          IconButton(
            icon: ProfileAvatar(
              radius: 25,
              profileImageUrl: _myProfileImageUrl,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ConversationsBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationLoaded) {
            final all = state.conversations;

            final filtered = _searchQuery.isEmpty
                ? all
                : all
                .where((c) => c.participantName
                .toLowerCase()
                .contains(_searchQuery))
                .toList();

            final recent = filtered.take(10).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    'Recent',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: 100,
                  child: recent.isEmpty
                      ? const Center(child: Text('No recent contacts'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final c = recent[index];
                      return _buildRecentContact(
                        context,
                        c.participantName,
                        c.profileImageUrl,
                        c.id,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: DefaultColors.messageListPage,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: filtered.isEmpty
                        ? const Center(
                      child: Text('No conversations found'),
                    )
                        : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final conversation = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  conversationId: conversation.id,
                                  mate: conversation.participantName,
                                  mateProfileImageUrl:
                                  conversation.profileImageUrl,
                                ),
                              ),
                            ).then((_) {
                              context.read<ConversationsBloc>().add(FetchConversations());
                            });
                          },
                          child: _buildMessageTile(
                            conversation.participantName,
                            conversation.lastMessage ?? 'No message',
                            conversation.lastMessageTime.toString(),
                            conversation.profileImageUrl,
                            conversation.unreadCount,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ConversationError) {
            return Center(child: Text(state.error));
          } else {
            return const Center(child: Text('No conversations found'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactsPage()),
          );
        },
        backgroundColor: DefaultColors.buttonColor,
        child: const Icon(Icons.contacts),
      ),
    );
  }

  Widget _buildMessageTile(
      String name,
      String message,
      String time,
      String? profileImageUrl,
      int unreadCount,
      ) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Stack(
        children: [
          ProfileAvatar(
            profileImageUrl: profileImageUrl,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minHeight: 20,
                  minWidth: 20,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.darkest,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        message,
        style: const TextStyle(color: AppColors.accent),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatMessageTime(time),
        style: const TextStyle(color: AppColors.primaryDark),
      ),
    );
  }

  Widget _buildRecentContact(
      BuildContext context,
      String name,
      String? profileImageUrl,
      String conversationId,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversationId,
              mate: name,
              mateProfileImageUrl: profileImageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            ProfileAvatar(
              profileImageUrl: profileImageUrl,
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 60,
              child: Text(
                name,
                style: TextStyle(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
