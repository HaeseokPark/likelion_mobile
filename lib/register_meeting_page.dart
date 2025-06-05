import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'userlist.dart';

class RegisterMeetingPage extends StatefulWidget {
  @override
  _RegisterMeetingPageState createState() => _RegisterMeetingPageState();
}

class _RegisterMeetingPageState extends State<RegisterMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  File? _selectedImage;
  List<Map<String, String>> _invitedFriends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _selectImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('meeting_images/$fileName');

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putFile(image, metadata);

      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return null;
    }
  }

  Future<void> _registerMeeting() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 필드를 입력해주세요.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      await FirebaseFirestore.instance.collection('meetings').add({
        'title': _titleController.text,
        'date': _selectedDate!.toIso8601String(),
        'start_time': _startTime!.format(context),
        'end_time': _endTime!.format(context),
        'content': _contentController.text,
        'invited_friends': _invitedFriends.map((f) => f['displayName'] ?? '').toList(),
        'imageUrl': imageUrl ?? '',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모임이 등록되었습니다!')));
      Navigator.pop(context);
    } catch (e) {
      print('등록 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 중 오류 발생: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 등록'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('제목'),
                    _buildTextField(_titleController, '모임 제목을 입력하세요'),

                    const SizedBox(height: 20),
                    _buildSectionLabel('날짜 및 시간'),
                    _buildDateTile('날짜 선택', _selectedDate == null
                        ? '선택 안됨'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                      Icons.calendar_today,
                      () => _selectDate(context),
                    ),
                    _buildDateTile('시작 시간', _startTime?.format(context) ?? '선택 안됨',
                      Icons.access_time,
                      () => _selectTime(context, true),
                    ),
                    _buildDateTile('종료 시간', _endTime?.format(context) ?? '선택 안됨',
                      Icons.access_time,
                      () => _selectTime(context, false),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionLabel('내용'),
                    _buildTextField(_contentController, '내용을 입력하세요', maxLines: 3),

                    const SizedBox(height: 20),
                    _buildSectionLabel('이미지'),
                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_selectedImage!, height: 150),
                          )
                        : OutlinedButton.icon(
                            onPressed: _selectImage,
                            icon: const Icon(Icons.image),
                            label: const Text('이미지 선택'),
                          ),

                    const SizedBox(height: 20),
                    _buildSectionLabel('친구 초대'),
                    ElevatedButton(
                      onPressed: _inviteFriends,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('친구 초대하기'),
                    ),

                    if (_invitedFriends.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _invitedFriends.map((f) {
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(f['displayName'] ?? '이름 없음'),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _registerMeeting,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('등록하기', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? '필수 항목입니다' : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateTile(String label, String value, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _inviteFriends() async {
    final selectedFriends = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserListPage()),
    );

    if (!mounted) return;

    if (selectedFriends != null && selectedFriends is List) {
      try {
        final friendsList = (selectedFriends as List)
            .whereType<Map<String, dynamic>>()
            .map((friend) => {
                  'uid': friend['uid'].toString(),
                  'displayName': friend['displayName'].toString(),
                })
            .toList();

        setState(() {
          _invitedFriends = friendsList;
        });
      } catch (e) {
        print("친구 변환 오류: $e");
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }
}
