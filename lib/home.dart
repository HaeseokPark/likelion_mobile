import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:likelion/detail.dart';
import 'package:likelion/widgets/global_appbar.dart';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:likelion/widgets/sort_filter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfCardsPerLine = 2;
  String _currentSort = '최신순';

  Stream<QuerySnapshot> _getMeetingsStream() {
    Query query = FirebaseFirestore.instance.collection('meetings');

    // 정렬 조건
    if (_currentSort == '최신순') {
      query = query.orderBy('created_at', descending: true);
    } else {
      query = query.orderBy('created_at', descending: false);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Column(
        children: [
          SizedBox(height: 20),
          SortFilter(
            currentSort: _currentSort,
            onSortChanged: (sortType) {
              setState(() {
                _currentSort = sortType;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMeetingsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text('등록된 모임이 없습니다.'));
                }

                return GridView.count(
                  crossAxisCount: numberOfCardsPerLine,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 8.0 / 9.0,
<<<<<<< HEAD
                  // GridView 내 docs.map 부분
children: docs.map((doc) {
  var data = doc.data() as Map<String, dynamic>;
  String title = data['title'] ?? '제목 없음';
  String date = data['date'] ?? '';
  String startTime = data['start_time'] ?? '';
  String content = data['content'] ?? '';
  String invitedFriend = data['invited_friend'] ?? '';
  String imageUrl = data['imageUrl'] ?? '';

  return Card(
    child: InkWell(
      onTap: () {
        // 상세 페이지 이동 구현 가능
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isNotEmpty
              ? Image.network(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover)
              : Container(height: 100, color: Colors.grey[300], child: Center(child: Text('이미지 없음'))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 4),
                Text('$date $startTime', style: Theme.of(context).textTheme.bodySmall),
                Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text('초대: $invitedFriend', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}).toList(),

=======
                  children:
                      docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String title = data['title'] ?? '제목 없음';
                        String date = data['date'] ?? '';
                        String startTime = data['start_time'] ?? '';
                        String content = data['content'] ?? '';
                        String invitedFriend = data['invited_friend'] ?? '';

                        return Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '$date $startTime',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '초대: $invitedFriend',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
>>>>>>> d26c574ab8fa708b06bad54584eba45a82191cdb
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: GlobalBottomBar(),
    );
  }
}
