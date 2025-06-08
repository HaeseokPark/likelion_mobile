import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'detail.dart'; // DetailPage import 추가

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String date,
    String time,
    String imageUrl,
    bool isUpcoming,
    String docId, // docId 추가
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(docId: docId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    )
                  : const Icon(Icons.image, size: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date [$time]',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUpcoming ? Icons.calendar_month : Icons.check,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.displayName == null) {
      return const Scaffold(
        appBar: GlobalAppBar(title: 'DO\'ST'),
        body: Center(child: Text('로그인된 사용자가 없습니다.')),
        bottomNavigationBar: GlobalBottomBar(selectedIndex: 0),
      );
    }

    final userName = currentUser.displayName!;
    final meetingsRef = FirebaseFirestore.instance
        .collection('meetings')
        .where('invited_friends', arrayContains: userName)
        .orderBy('date');

    final today = DateTime.now();

    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: meetingsRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final upcoming = <Widget>[];
            final past = <Widget>[];

            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? '';
              final rawDateStr = data['date'] ?? '';
              final start = data['start_time'] ?? '';
              final end = data['end_time'] ?? '';
              final timeRange = '$start~$end';
              final imageUrl = data['imageUrl'] ?? '';
              final docId = doc.id;

              final date = DateTime.tryParse(rawDateStr);
              if (date == null) continue;

              final dateStr = DateFormat('yy/MM/dd').format(date);

              final item = _buildActivityItem(
                context,
                title,
                dateStr,
                timeRange,
                imageUrl,
                !date.isBefore(today),
                docId,
              );

              if (date.isBefore(today)) {
                past.add(item);
              } else {
                upcoming.add(item);
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
      bottomNavigationBar: GlobalBottomBar(selectedIndex: 0),
    );
  }
}
