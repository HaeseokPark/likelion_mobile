import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
  final TextEditingController _friendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
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

  Future<void> _registerMeeting() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _startTime != null && _endTime != null) {
      await FirebaseFirestore.instance.collection('meetings').add({
        'title': _titleController.text,
        'date': _selectedDate!.toIso8601String(),
        'start_time': _startTime!.format(context),
        'end_time': _endTime!.format(context),
        'content': _contentController.text,
        'invited_friend': _friendController.text,
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
              TextFormField(
                controller: _friendController,
                decoration: InputDecoration(labelText: '친구 초대 (이름)'),
              ),
              SizedBox(height: 20),
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
}
