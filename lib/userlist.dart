import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _users = [];
  Map<String, GlobalKey> _itemKeys = {};
  String? _highlightedUid;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('displayName')
        .get();

    setState(() {
      _users = snapshot.docs;
      _itemKeys = {
        for (var doc in _users) doc.id: GlobalKey(),
      };
    });
  }

  void _scrollToUser(String name) {
    for (final doc in _users) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['displayName'] as String?)?.toLowerCase() == name.toLowerCase()) {
        final key = _itemKeys[doc.id];
        if (key != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _highlightedUid = doc.id;
          });

          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _highlightedUid = null;
            });
          });
        }
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('해당 이름의 유저를 찾을 수 없습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('유저 목록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '이름으로 검색',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _scrollToUser(_searchController.text.trim());
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _scrollToUser(value.trim());
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final doc = _users[index];
                final data = doc.data() as Map<String, dynamic>;
                final isHighlighted = _highlightedUid == doc.id;

                return Container(
                  key: _itemKeys[doc.id],
                  color: isHighlighted ? Colors.yellow[100] : null,
                  child: ListTile(
                    leading: data['photoURL'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(data['photoURL']),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['displayName'] ?? '이름 없음'),
                    subtitle: Text(data['email'] ?? ''),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
