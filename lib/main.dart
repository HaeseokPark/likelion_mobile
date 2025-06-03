import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:likelion/detail.dart';
import 'package:likelion/home.dart';
import 'package:likelion/userlist.dart';
import 'firebase_options.dart';
import 'login.dart'; 
import 'register_meeting_page.dart';

// 예를 들어 메인 화면을 GroupDetailPage로 설정한다고 가정

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/detail', // 초기 라우트는 로그인
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/logout': (BuildContext context) => const LoginPage(),
        '/home': (BuildContext context) => HomePage(), 
        '/register': (BuildContext context) => RegisterMeetingPage(), 
        '/user': (BuildContext context) => UserListPage(),
        '/detail': (BuildContext context) => DetailPage(),
      },
    );
  }
}
