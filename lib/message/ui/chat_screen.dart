// lib/message/ui/chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:likelion/message/DI/service_locator.dart';
import 'package:likelion/message/services/auth/auth_service.dart';
import 'package:likelion/message/services/chat/chat_services.dart';
import 'package:likelion/message/widgets/chat_bubble.dart';
import 'package:likelion/message/widgets/my_textfield.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });
  final String receiverEmail;
  final String receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  late ChatService _chatService;
  late AuthServices _authService;

  @override
  void initState() {
    super.initState();
    _chatService = locator.get<ChatService>();
    _authService = locator.get<AuthServices>();

    myFocusNode.addListener(
      () {
        if (myFocusNode.hasFocus) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => scrollDown(),
          );
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => scrollDown(),
      );
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.decelerate,
      );
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, controller.text);
      controller.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0, left: 25, right: 25),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hint: "Enter your message",
                    obsecure: false,
                    controller: controller,
                    focusNode: myFocusNode,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String? senderID = _authService.getCurrentuser()?.uid;
    if (senderID == null) {
      return const Center(child: Text("사용자 ID를 불러올 수 없습니다."));
    }

    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverId, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "Error: ${snapshot.error}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Loading",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SpinKitWanderingCubes(
                  color: Theme.of(context).colorScheme.primary,
                  size: 30.0,
                ),
              ],
            ),
          );
        }
        return ListView(
          controller: scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurentUser = data['senderId'] == _authService.getCurrentuser()!.uid;

    return ChatBubble(
      isCurrentUser: isCurentUser,
      message: data["message"],
    );
  }
}