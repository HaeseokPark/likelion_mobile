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
  final Map<String, bool> _selectedUsers = {};

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
      for (var doc in _users) {
        _selectedUsers[doc.id] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유저 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final selected = _users
                  .where((doc) => _selectedUsers[doc.id] == true)
                  .map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'uid': doc.id,
                      'displayName': data['displayName'] ?? '이름 없음',
                    };
                  })
                  .toList();
              if (selected.isNotEmpty) {
                Navigator.pop(context, selected); // 선택된 친구 데이터 반환
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('친구를 선택하세요.')),
                );
              }
            },
          ),
        ],
      ),
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
                  onPressed: () => setState(() {}),
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final doc = _users[index];
                final data = doc.data() as Map<String, dynamic>;
                final displayName = data['displayName'] ?? '이름 없음';
                final email = data['email'] ?? '';
                final searchFilter = _searchController.text.trim().toLowerCase();

                if (searchFilter.isNotEmpty &&
                    !displayName.toLowerCase().contains(searchFilter)) {
                  return const SizedBox.shrink();
                }

                return CheckboxListTile(
                  value: _selectedUsers[doc.id],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedUsers[doc.id] = value ?? false;
                    });
                  },
                  title: Text(displayName),
                  subtitle: Text(email),
                  secondary: data['photoURL'] != null
                      ? CircleAvatar(backgroundImage: NetworkImage(data['photoURL']))
                      : const CircleAvatar(child: Icon(Icons.person)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
