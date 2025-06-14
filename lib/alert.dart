import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> notifications = [
    '축구 할 사람',
    '공부 할 사람',
    '산책 할 사람',
    '게임 할 사람',
  ];

  void _saveNotification(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined: ${notifications[index]}')),
    );
    setState(() {
      notifications.removeAt(index);
    });
  }

  void _deleteNotification(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dismissed: ${notifications[index]}')),
    );
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 목록'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(notifications[index]),
            background: _buildSwipeActionLeft(),
            secondaryBackground: _buildSwipeActionRight(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _saveNotification(index);
              } else if (direction == DismissDirection.endToStart) {
                _deleteNotification(index);
              }
              return false;
            },
            child: Card(
              child: ListTile(
                title: Text(notifications[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.bookmark, color: Colors.white),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete, color: Colors.white),
    );
  }

  
}
