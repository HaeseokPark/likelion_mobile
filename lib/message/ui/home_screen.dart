// lib/home.dart (ChatHomeScreen)

import 'package:flutter/material.dart';
import 'package:likelion/message/DI/service_locator.dart';
import 'package:likelion/message/services/auth/auth_service.dart';
import 'package:likelion/message/services/chat/chat_services.dart';
import 'package:likelion/message/ui/chat_screen.dart';
import 'package:likelion/message/widgets/my_drawer.dart';
import 'package:likelion/message/widgets/usertile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:likelion/message/widgets/my_textfield.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  // 서비스 인스턴스
  final ChatService _chatService = locator.get<ChatService>();
  final AuthServices _authService = locator.get<AuthServices>();

  // 검색 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // 전체 사용자 목록과 필터링된 사용자 목록
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  // 현재 사용자 ID
  String? _currentUserId;

  // 스트림 구독을 위한 변수
  late final Stream<List<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentuser()?.uid;

    if (_currentUserId == null) {
      // 사용자 ID를 불러올 수 없는 경우, 에러 메시지를 표시하고 더 이상 진행하지 않음
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인 해주세요.')),
        );
      });
      return; // initState는 void이므로 return으로 함수를 종료
    }

    // 사용자 스트림 정의
    _userStream = _chatService.getuserStream();

    // 스트림 구독
    _userStream.listen((users) {
      if (!mounted) {
        print("ChatHomeScreen: Widget is unmounted, not updating state.");
        return;
      }
      print("ChatHomeScreen: Received ${users.length} users from stream.");

      setState(() {
        _allUsers = users
            .where((userData) => userData['uid'] != _currentUserId) // 현재 사용자 제외
            .toList();
        print("ChatHomeScreen: _allUsers (excluding current user): ${_allUsers.length} users.");
        _filterUsers(); // 검색어에 따라 초기 필터링 (초기 로드 시에도 실행)
        print("ChatHomeScreen: _filteredUsers after initial filter: ${_filteredUsers.length} users.");
      });
    }, onError: (error) {
      // 에러 처리
      print("ChatHomeScreen Error fetching users: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 목록을 불러오는 데 오류가 발생했습니다: $error')),
        );
      }
    });

    // 검색어 변경 리스너
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // 검색어에 따라 사용자 목록을 필터링하는 함수
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final email = user['email']?.toLowerCase() ?? '';
        // displayName이 없다면 email로 검색, 있다면 displayName으로도 검색
        final displayName = user['displayName']?.toLowerCase() ?? '';

        return email.contains(query) || displayName.contains(query);
      }).toList();
      print("ChatHomeScreen: Filtered users for query '$query': ${_filteredUsers.length} users.");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      // initState에서 이미 SnackBar를 띄웠지만, 혹시 모를 경우를 대비하여 화면에도 표시
      return const Scaffold(
        body: Center(child: Text("로그인 정보가 없습니다. 다시 로그인 해주세요.")),
      );
    }

    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: const Text("HOME"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyTextField(
              controller: _searchController,
              hint: "친구 검색...",
              obsecure: false,
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_allUsers.isEmpty && _searchController.text.isEmpty) {
      // 아직 데이터를 불러오는 중이거나, 불러올 친구가 없는 경우
      // _allUsers가 비어있고 검색어가 없는 경우에만 로딩 스피너 표시
      // 이 경우, _userStream.listen() 콜백이 아직 실행되지 않았거나,
      // 스트림이 빈 리스트를 반환했거나, 현재 사용자만 존재하는 경우임.
      print("ChatHomeScreen: Showing loading spinner. _allUsers.isEmpty: ${_allUsers.isEmpty}, _searchController.text.isEmpty: ${_searchController.text.isEmpty}");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Loading Friends...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            SpinKitWanderingCubes(
              color: Theme.of(context).colorScheme.primary,
              size: 30.0,
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      // _filteredUsers가 비어있지만, _allUsers는 비어있지 않은 경우
      // (검색 결과가 없거나, 나 자신만 있는 경우)
      print("ChatHomeScreen: Showing no results. _filteredUsers.isEmpty: ${_filteredUsers.isEmpty}");
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? "검색 결과가 없습니다."
              : "채팅 가능한 다른 친구가 없습니다.", // 나 자신 외에 친구가 없는 경우
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
      );
    }

    // 친구 목록이 있는 경우
    print("ChatHomeScreen: Displaying ${_filteredUsers.length} filtered users.");
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final userData = _filteredUsers[index];
        return UserTile(
          text: userData["displayName"] ?? userData["email"] ?? "알 수 없는 사용자",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiverEmail: userData["email"] ?? "알 수 없는 이메일",
                  receiverId: userData["uid"] ?? "",
                ),
              ),
            );
          },
        );
      },
    );
  }
}