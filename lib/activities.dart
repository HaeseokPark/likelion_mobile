import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  Widget _buildActivityItem(
    String title,
    String date,
    String time,
    String imageUrl,
    bool _isDone,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Flexible(
  child: Image.network(
    imageUrl,
    width: 30,         
    height: 30,       
    fit: BoxFit.cover, 
  ),
),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date [$time]',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _isDone
              ? Icon(Icons.calendar_month)
              : Icon(Icons.check)
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesRef = FirebaseFirestore.instance.collection('meetings');
    final today = DateTime.now();

    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: activitiesRef.orderBy('date', descending: false).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('오류 발생'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            final upcoming = <Widget>[];
            final past = <Widget>[];

            for (final doc in docs) {
              print(doc.data());
              final title = doc['title'] ?? '';
              final rawDateStr = doc['date'] ?? '';
              final start = doc['start_time'] ?? '';
              final end = doc['end_time'] ?? '';
              final timeRange = '$start~$end';
              final imageUrl = doc['imageUrl'] ?? '';

              final date = DateTime.tryParse(rawDateStr);
              final dateStr =
                  date != null ? DateFormat('yy/MM/dd').format(date) : '';

              if (date != null && date.isBefore(today)) {
                past.add(
                  _buildActivityItem(title, dateStr, timeRange, imageUrl, false),
                );
              } else {
                upcoming.add(
                  _buildActivityItem(title, dateStr, timeRange, imageUrl, true),
                );
              }
            }

            return ListView(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "참여할 일정",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...upcoming,
                const SizedBox(height: 24),
                const Text(
                  "참여했던 일정",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...past,
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: GlobalBottomBar(selectedIndex: 1),
    );
  }
}
