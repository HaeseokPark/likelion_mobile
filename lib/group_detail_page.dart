import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';


class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key});
  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
  final TextEditingController _contentController = TextEditingController();

  List<String> friends = ['김철수', '이영희', '박민수', '정예은'];
  String? selectedFriend;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedTimeStart = picked;
        } else {
          _selectedTimeEnd = picked;
        }
      });
    }
  }

  void _inviteFriend() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: friends.map((f) {
            return ListTile(
              title: Text(f),
              trailing: Icon(Icons.person_add),
              onTap: () {
                setState(() {
                  selectedFriend = f;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? '날짜 선택'
        : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}';

    final timeText = (_selectedTimeStart != null && _selectedTimeEnd != null)
        ? '${_selectedTimeStart!.format(context)} ~ ${_selectedTimeEnd!.format(context)}'
        : '시간 설정';

    return Scaffold(
      appBar: AppBar(
        title: const Text('할사람'),
        centerTitle: true,
        leading: Icon(Icons.people),
        actions: const [Padding(padding: EdgeInsets.all(8), child: Icon(Icons.menu))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Row(
                  children: const [
                    CircleAvatar(child: Text('A')),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('이름: 박해석', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('22100322'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
                const SizedBox(height: 16),
                const Text('제목: 축구 할 사람~~'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                    Text(dateText),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _pickTime(true),
                      child: const Text('시작 시간 선택'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _pickTime(false),
                      child: const Text('종료 시간 선택'),
                    ),
                  ],
                ),
                Text('시간: $timeText'),
                const SizedBox(height: 12),
                const Text('내용:'),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '내용을 입력하세요...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('친구 초대하기: '),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: _inviteFriend,
                    ),
                    if (selectedFriend != null) Text('-> $selectedFriend'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 등록 로직 작성 가능
                    print('등록됨');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('등록하기'),
                  ),
                ),
                
//스와이프버튼

                SwipeButton.expand(
                  thumb: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      IconData(0xe5f2, fontFamily: 'MaterialIcons'),
                      size: 53,
                    ),
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.grey.shade300,
                  onSwipe: () { 
                    //저장 후 페이지 바뀌는 로직 추가
                  },
                  child: Text(
                    "참여하기",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}