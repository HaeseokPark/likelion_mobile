import 'package:flutter/material.dart';

class GlobalBottomBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '설정'),
        BottomNavigationBarItem(icon: Icon(Icons.star_border), label: '메인'),
        BottomNavigationBarItem(icon: Icon(Icons.star_border), label: '스케줄'),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
