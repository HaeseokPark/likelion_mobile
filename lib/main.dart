import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:likelion/activities.dart';
import 'package:likelion/home.dart';
import 'package:likelion/mypage.dart';
import 'package:likelion/userlist.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'register_meeting_page.dart';

import 'calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await initSerivceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', 
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/anilogin': (BuildContext context) => const LoginPage(),
        '/logout': (BuildContext context) => const LoginPage(),
        '/home': (BuildContext context) => HomePage(),
        '/register': (BuildContext context) => RegisterMeetingPage(),
        '/mypage': (BuildContext context) => MyPage(),
        '/user': (BuildContext context) => UserListPage(),
        '/activities': (BuildContext context) => ActivityPage(),
        '/calendar': (BuildContext context) => CalendarPage(),
      },
    );
  }
}
