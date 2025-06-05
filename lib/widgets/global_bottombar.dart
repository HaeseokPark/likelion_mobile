import 'package:flutter/material.dart';
import 'package:likelion/home.dart';
import 'package:likelion/calendar.dart';

class GlobalBottomBar extends StatelessWidget {
  const GlobalBottomBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 1) {
          // 메인
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (index == 2) {
          // 스케줄
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarPage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '메인'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '스케줄'),
      ],
    );
  }
}
