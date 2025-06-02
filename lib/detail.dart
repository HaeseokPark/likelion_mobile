import 'package:flutter/material.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: ListView(
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
                    const Text(
                      // 파이어 베이스에서 불러오기
                      '축구할 사람',
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
          const SizedBox(height: 30),
          const Text(
            '설명',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // 파이어 베이스에서 불러오기
          const Text('• 일시\n  7월 11일 19:00 ~ 22:00 (금)'),
          const SizedBox(height: 8),
          // 파이어 베이스에서 불러오기
          const Text('• 장소\n  [히딩크 드림필드]'),
          const SizedBox(height: 8),
          // 파이어 베이스에서 불러오기
          const Text('• 모집 인원\n  10명'),
          const SizedBox(height: 8),
          // 파이어 베이스에서 불러오기
          const Text('• 조건\n  풋살화 있는 사람'),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '참가자 명단',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                }, 
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('participants').snapshots(),
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
                      children: participants.map((doc) {
                        final name = doc['name'] ?? '이름 없음';
                        final imageUrl = doc['imageUrl'] ?? ''; // 이미지 없으면 빈 문자열
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _participantCard(name, imageUrl), // 이름과 이미지로 카드 생성
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomBar(),
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

