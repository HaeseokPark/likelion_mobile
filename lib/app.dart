import 'package:flutter/material.dart';
import 'package:likelion/home.dart';
import 'package:likelion/login.dart';



class DoStApp extends StatelessWidget {
  const DoStApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO\'ST',
      initialRoute: '/home',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/logout': (BuildContext context) => const LoginPage(),
        '/home': (BuildContext context) => HomePage(), 
      },
      theme: ThemeData.light(useMaterial3: true).copyWith(
        // primarySwatch: Colors.blue,
      ),
    );
  }
}
