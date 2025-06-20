import 'package:flutter/material.dart';
import 'package:likelion/home.dart';
import 'package:likelion/mypage.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlobalAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      leading: IconButton(
        icon: Image.asset('assets/images/DOST-logo.png'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      title: Text(title, style: TextStyle(color: Colors.black)),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
