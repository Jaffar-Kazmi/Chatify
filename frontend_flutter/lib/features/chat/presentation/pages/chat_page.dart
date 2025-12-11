import 'package:chat_app/core/widgets/profile_avatar.dart';
import 'package:chat_app/features/chat/data/datasources/messages_remote_data_sources.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  final String? mateProfileImageUrl;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.mate,
    this.mateProfileImageUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  String userId = '';
  String botId = "00000000-0000-0000-0000-000000000000";

  // SEARCH STATE  -----------------------------
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context)
        .add(LoadMessagesEvent(widget.conversationId));
    fetchUserId();
  }

  fetchUserId() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<ChatBloc>(context)
          .add(SendMessageEvent(widget.conversationId, content));
      _messageController.clear();
    }
  }

  // OPEN CAMERA  ------------------------------
  Future<void> _openCamera() async {
    final XFile? photo =
    await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;
    // TODO: upload + send as image message
    print('Picked image: ${photo.path}');
  }

  // DELETE CONVERSATION -----------------------
  Future<void> _onDeleteConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete chat'),
        content: const Text(
            'Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      BlocProvider.of<ChatBloc>(context)
          .add(DeleteConversationEvent(widget.conversationId));

      final conversationsBloc = context.read<ConversationsBloc>();
      conversationsBloc.add(FetchConversations());

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style:
          const TextStyle(fontSize: 16, color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search in chat',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        )
            : Row(
          children: [
            ProfileAvatar(
              profileImageUrl: widget.mateProfileImageUrl,
              radius: 22,
            ),
            const SizedBox(width: 10),
            Text(
              widget.mate,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent,),
            onPressed: _onDeleteConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ChatLoadedState) {
                  final all = state.messages;
                  final filtered = _searchQuery.isEmpty
                      ? all
                      : all
                      .where((m) => m.content
                      .toLowerCase()
                      .contains(_searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No messages found.'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final message = filtered[index];
                      final isSentMessage = message.senderId == userId;
                      final isDailyQuestion =
                          message.senderId == botId;

                      if (isSentMessage) {
                        return _buildSentMessage(
                            context, message.content);
                      } else if (isDailyQuestion) {
                        return _buildDailyQuestionMessage(
                            context, message.content);
                      } else {
                        return _buildReceivedMessage(
                            context, message.content);
                      }
                    },
                  );
                } else if (state is ChatErrorState) {
                  return Center(child: Text(state.error));
                }
                return const Center(child: Text('No messages found.'));
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.only(left: 20, top: 5, bottom: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomRight: Radius.circular(15), bottomLeft: Radius.circular(3)),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryDark
          ),
        ),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin:
        const EdgeInsets.only(right: 20, top: 5, bottom: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(3)),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            child: const Icon(
              Icons.camera_alt,
              color: AppColors.primaryLight,
            ),
            onTap: _openCamera,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Enter message",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            child: const Icon(
              Icons.send,
              color: AppColors.primaryLight,
            ),
            onTap: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestionMessage(
      BuildContext context, String message) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.dailyQuestionColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '🤖 Daily Question: $message',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ),
    );
  }
}
