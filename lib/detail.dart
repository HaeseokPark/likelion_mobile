import 'package:flutter/material.dart';
import 'package:likelion/widgets/date_formatter.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:shimmer/shimmer.dart';


class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.docId});

  final String docId;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserName = currentUser?.displayName ?? '익명'; // 로그인된 사용자 이름

    final docRef = FirebaseFirestore.instance.collection('meetings').doc(docId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      appBar: AppBar(title: const Text('모임 상세'), backgroundColor: Colors.blue),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('해당 문서를 찾을 수 없습니다.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final title = data['title'] ?? '제목 없음';
          final date = data['date'] ?? '';
          final startTime = data['start_time'] ?? '';
          final endTime = data['end_time'] ?? '';
          final imageUrl = data['imageUrl'] ?? '';
          final List<dynamic> friends = data['invited_friends'] ?? [];

          final bool isParticipant = friends.contains(currentUserName);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Image load error: $error');
                              return const Icon(Icons.broken_image);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          )
                        : Image.asset('assets/DOST-logo.png'),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '25/07/11 [19:00-21:00]', // 이 부분 필요시 formatMeetingDate로 변경
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (isParticipant) {
                              // 떠나기: 리스트에서 제거
                              await docRef.update({
                                'invited_friends': FieldValue.arrayRemove([currentUserName])
                              });
                            } else {
                              // 참여하기: 리스트에 추가
                              await docRef.update({
                                'invited_friends': FieldValue.arrayUnion([currentUserName])
                              });
                            }

                            // 화면 새로고침
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => DetailPage(docId: docId)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(isParticipant ? '떠나기' : '참여하기'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '설명',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('• 일시\n  ${formatMeetingDate(date, startTime, endTime)}'),
              const SizedBox(height: 8),
              Text('• 장소\n  ${data['location'] ?? '[장소 정보 없음]'}'),
              const SizedBox(height: 8),
              Text(
                data['capacity'] != null ? '• 모집 인원\n  ${data['capacity']}명' : '• 모집 인원\n  [미정]',
              ),
              const SizedBox(height: 8),
              Text('• 조건\n  ${data['condition'] ?? '[없음]'}'),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '참가자 명단',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (friends.isNotEmpty)
                    ...friends.map<Widget>((name) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• $name'),
                        ))
                  else
                    const Text('참가자 정보가 없습니다.'),
                ],
              ),
              const SizedBox(height: 10),

              SwipeButton.expand(
                width: 300,
                thumb: const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    IconData(0xe5f2, fontFamily: 'MaterialIcons'),
                    size: 53,
                    color: Colors.white,
                  ),
                ),
                activeThumbColor: Colors.blue,
                activeTrackColor: Colors.blue,
                onSwipe: () async {
                  if (!isParticipant) {
                    await docRef.update({
                      'invited_friends': FieldValue.arrayUnion([currentUserName])
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DetailPage(docId: docId)),
                    );
                  }
                },
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.lightBlue,
                  child: Text(
                    isParticipant ? '참여 완료' : '참여하기',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const GlobalBottomBar(selectedIndex: 1),
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
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(name),
      ],
    );
  }
}
