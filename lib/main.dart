import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'group_detail_page.dart'; // 예를 들어 메인 화면을 GroupDetailPage로 설정한다고 가정
import 'alert.dart';
import 'mypage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // 초기 라우트는 로그인
      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => const ProfilePage(), // 메인 라우트 등록
      },
    );
  }
}
