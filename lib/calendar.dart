import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/global_appbar.dart';
import 'widgets/global_bottombar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar with Events',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Map<DateTime, List<String>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('meetings').get();

      final Map<DateTime, List<String>> loadedEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['title'] ?? '제목 없음';
        final dateString = data['date'];

        if (dateString is String) {
          try {
            final date = DateTime.parse(dateString);
            final eventDate = DateTime(date.year, date.month, date.day);

            if (loadedEvents[eventDate] == null) {
              loadedEvents[eventDate] = [name];
            } else {
              loadedEvents[eventDate]!.add(name);
            }
          } catch (e) {
            print('날짜 파싱 오류: $e');
          }
        }
      }

      setState(() {
        _events.clear();
        _events.addAll(loadedEvents);
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerMargin: EdgeInsets.symmetric(horizontal: 1.5),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: _buildMarkers(events.length),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomBar(num: 2),
    );
  }

  Widget _buildMarkers(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) =>
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        )
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);
    if (events.isEmpty) {
      return const Center(child: Text('일정이 없습니다.'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.event),
        title: Text(events[index]),
      ),
    );
  }
}
