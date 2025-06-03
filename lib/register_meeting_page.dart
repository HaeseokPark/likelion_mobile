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
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _contentController = TextEditingController();

  File? _selectedImage;
  List<Map<String, String>> _invitedFriends = []; // uid와 displayName 저장

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _selectImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('meeting_images/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _registerMeeting() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _startTime != null && _endTime != null) {
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
        'invited_friends': _invitedFriends, // Firestore에 초대한 친구들 저장
        'imageUrl': imageUrl ?? '',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모임이 등록되었습니다!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 필드를 입력해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('모임 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력하세요' : null,
              ),
              ListTile(
                title: Text(_selectedDate == null ? '날짜 선택' : '날짜: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(_startTime == null ? '시작 시간 선택' : '시작: ${_startTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(_endTime == null ? '종료 시간 선택' : '종료: ${_endTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 3,
              ),
              ElevatedButton(
                onPressed: () async {
  final selectedFriends = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const UserListPage()),
  );
  if (selectedFriends != null && selectedFriends is List) {
    setState(() {
      _invitedFriends = List<Map<String, String>>.from(selectedFriends);
    });
  }
},

                child: Text('친구 초대하기'),
              ),
              if (_invitedFriends.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('초대한 친구들:'),
                    ..._invitedFriends.map((f) => Text('- ${f['displayName']} (uid: ${f['uid']})')).toList(),
                  ],
                ),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : ElevatedButton.icon(
                      onPressed: _selectImage,
                      icon: Icon(Icons.image),
                      label: Text('이미지 선택'),
                    ),
              ElevatedButton(
                onPressed: _registerMeeting,
                child: Text('등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
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
