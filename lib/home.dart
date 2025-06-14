import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:likelion/detail.dart';
import 'package:likelion/message/widgets/my_drawer.dart';
import 'package:likelion/widgets/date_formatter.dart';
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
      drawer: MyDrawer(),
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
                  children:
                      docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String title = data['title'] ?? '제목 없음';
                        String date = data['date'] ?? '';
                        String startTime = data['start_time'] ?? '';
                        String endTime = data['end_time'] ?? '';
                        String content = data['content'] ?? '';
                        String invitedFriend = data['invited_friend'] ?? '';
                        String imageUrl = data['imageUrl'] ?? '';

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailPage(docId: doc.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 이미지 영역 (카드 상단과 꼭 맞게)
                                SizedBox(
                                  height: 90,
                                  width: double.infinity,
                                  child:
                                      imageUrl.isNotEmpty &&
                                              imageUrl.startsWith('http')
                                          ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              print('Image load error: $error');
                                              return Icon(Icons.broken_image);
                                            },
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          )
                                          : Image.asset(
                                            'assets/images/DOST-logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        formatMeetingDate(
                                          date,
                                          startTime,
                                          endTime,
                                        ),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      // SizedBox(height: 4),
                                      // Text(
                                      //   '초대: $invitedFriend',
                                      //   style:
                                      //       Theme.of(
                                      //         context,
                                      //       ).textTheme.bodySmall,
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
      bottomNavigationBar: GlobalBottomBar(selectedIndex: 1),
    );
  }
}
