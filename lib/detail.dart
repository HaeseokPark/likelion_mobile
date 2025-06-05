import 'package:flutter/material.dart';
import 'package:likelion/widgets/date_formatter.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:shimmer/shimmer.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.docId});

  final String docId;

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('meetings').doc(docId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('해당 문서를 찾을 수 없습니다.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final title = data['title'] ?? '제목 없음';
          final date = data['date'] ?? '';
          final startTime = data['start_time'] ?? '';
          final endTime = data['end_time'] ?? '';
          final content = data['content'] ?? '';
          final imageUrl = data['image_url'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 파이어 베이스에서 불러오기
                  Flexible(child: Image.asset('assets/DOST-logo.png')),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Text(
                          // 파이어 베이스에서 불러오기
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          // 파이어 베이스에서 불러오기
                          '25/07/11 [19:00-21:00]',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('참여하기'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                '설명',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Text('• 일시\n  ${formatMeetingDate(date, startTime, endTime)}'),
              SizedBox(height: 8),

              Text('• 장소\n  ${data['location'] ?? '[장소 정보 없음]'}'),
              SizedBox(height: 8),

              Text(data['capacity'] != null
                ? '• 모집 인원\n  ${data['capacity']}명'
                : '• 모집 인원\n  [미정]',
              ),
              SizedBox(height: 8),

              Text('• 조건\n  ${data['condition'] ?? '[없음]'}'),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '참가자 명단',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('participants')
                            .snapshots(),
                    builder: (context, snapshot) { 
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // 로딩 중이면 동그란 로딩 표시
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('참가자가 없습니다.'); // 데이터 없을 때
                      }

                      final participants = snapshot.data!.docs; // 문서들 가져오기

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              participants.map((doc) {
                                final name = doc['name'] ?? '이름 없음';
                                final imageUrl =
                                    doc['imageUrl'] ?? ''; // 이미지 없으면 빈 문자열
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _participantCard(
                                    name,
                                    imageUrl,
                                  ), // 이름과 이미지로 카드 생성
                                );
                              }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SwipeButton.expand(
                width: 300,
                thumb: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    IconData(0xe5f2, fontFamily: 'MaterialIcons'),
                    size: 53,
                    color: Colors.white,
                  ),
                ),
                activeThumbColor: Colors.blue,
                activeTrackColor: Colors.blue,
                onSwipe: () { 
                  Navigator.pushReplacementNamed(context, '/activities');
                },
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.lightBlue,
                  child: Text(
                    '참여하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: GlobalBottomBar(selectedIndex: 0), // or appropriate index

    );
  }

  Widget _participantCard(String name, String imageUrl) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.person),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(name),
      ],
    );
  }
}
