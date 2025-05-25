import 'package:flutter/material.dart';
import 'package:likelion/model/promise';
import 'package:likelion/widgets/global_bottombar.dart';
import 'widgets/global_appbar.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required Promise promise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("서병주", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 4),
                        Text("22100356", style: TextStyle(color: Colors.grey)),

                        SizedBox(height: 12),
                        Text("• 방 만든 횟수 : 12개"),
                        Text("• 참여한 횟수 : 23개"),
                        Text("• 참여 온도: 36.9도"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ElevatedButton.icon(
            //   onPressed: () {
            //     // 수정하기 눌렀을 때 동작
            //   },
            //   icon: const Icon(Icons.edit),
            //   label: const Text("수정하기"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     foregroundColor: Colors.deepPurple,
            //     elevation: 4,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //       side: const BorderSide(color: Colors.deepPurple),
            //     ),
            //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //   ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 수정하기 눌렀을 시
        },
        // backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // 하단 네비게이션 바
      bottomNavigationBar: GlobalBottomBar(),
    );
  }
}
