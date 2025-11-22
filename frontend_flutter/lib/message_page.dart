import 'package:chat_app/core/theme.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

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
          )
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
              child: ListView(
                children: [
                  _buildMessageTile('Zain Ali', 'Hello', '10:00 AM'),
                  _buildMessageTile('Jaffar', 'Kesy ho?', '10:09 AM'),
                  _buildMessageTile('Raza', 'What are you doing?', '08:18 AM'),
                  _buildMessageTile('Kaleem', 'Aa jao', '10:00 AM'),
                  _buildMessageTile('Ehtisham Hussain', 'Kia hal', '10:00 AM'),
                  _buildMessageTile('Hassan', 'Mn thk', '10:00 AM'),
                  _buildMessageTile('Fakhar', 'Hi', '10:00 AM'),
                  ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildMessageTile(String name, String message, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage("https://placehold.co/400"),
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
          backgroundImage: NetworkImage('https://placehold.co/400'),
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
