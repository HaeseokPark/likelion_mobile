// 필요한 패키지 추가 필요:
// google_maps_flutter: ^2.5.0
// geolocator: ^11.0.0

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';
import 'userlist.dart';

class RegisterMeetingPage extends StatefulWidget {
  @override
  _RegisterMeetingPageState createState() => _RegisterMeetingPageState();
}

class _RegisterMeetingPageState extends State<RegisterMeetingPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _selectedImage;
  List<Map<String, String>> _invitedFriends = [];

  String? _locationDisplay;
  LatLng? _pickedLocation;

  bool _isLoading = false;

  final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _selectImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('meeting_images/$fileName');
      await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return null;
    }
  }

  Future<void> _pickLocationOnMap() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapLocationPickerPage()),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _locationDisplay = '${result.latitude}, ${result.longitude}';
      });
    }
  }

  Future<void> _registerMeeting() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) imageUrl = await _uploadImage(_selectedImage!);

      await FirebaseFirestore.instance.collection('meetings').add({
        'title': _titleController.text.trim(),
        'location': _locationDisplay,
        'lat': _pickedLocation!.latitude,
        'lng': _pickedLocation!.longitude,
        'capacity': int.parse(_capacityController.text),
        'date': _selectedDate!.toIso8601String(),
        'start_time': _startTime!.format(context),
        'end_time': _endTime!.format(context),
        'content': _contentController.text.trim(),
        'invited_friends': _invitedFriends.map((f) => f['displayName'] ?? '').toList(),
        'imageUrl': imageUrl ?? '',
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임이 등록되었습니다!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('등록 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 중 오류 발생: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모임 등록'), centerTitle: true),
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
                    _buildSectionLabel('장소'),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.place),
                        title: Text(_locationDisplay ?? '지도를 열어 장소를 선택하세요'),
                        trailing: Icon(Icons.map),
                        onTap: _pickLocationOnMap,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionLabel('모집 인원'),
                    _buildTextField(
                      _capacityController,
                      '숫자만 입력',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return '필수 항목입니다';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return '1 이상의 정수를 입력';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildSectionLabel('날짜 및 시간'),
                    _buildDateTile(
                      '날짜 선택',
                      _selectedDate == null ? '선택 안됨' : _selectedDate!.toLocal().toString().split(' ').first,
                      Icons.calendar_today,
                      () => _selectDate(context),
                    ),
                    _buildDateTile(
                      '시작 시간',
                      _startTime?.format(context) ?? '선택 안됨',
                      Icons.access_time,
                      () => _selectTime(context, true),
                    ),
                    _buildDateTile(
                      '종료 시간',
                      _endTime?.format(context) ?? '선택 안됨',
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
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('친구 초대하기'),
                    ),
                    if (_invitedFriends.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _invitedFriends
                            .map((f) => ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(f['displayName'] ?? '이름 없음'),
                                ))
                            .toList(),
                      ),

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: _primaryButtonStyle,
                        onPressed: _registerMeeting,
                        child: const Text('등록하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ?? (v) => v == null || v.isEmpty ? '필수 항목입니다' : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateTile(String label, String value, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      MaterialPageRoute(builder: (_) => const UserListPage()),
    );

    if (!mounted) return;
    if (selectedFriends is List) {
      setState(() {
        _invitedFriends = selectedFriends
            .whereType<Map<String, dynamic>>()
            .map((f) => {
                  'uid': f['uid'].toString(),
                  'displayName': f['displayName'].toString(),
                })
            .toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
}

class MapLocationPickerPage extends StatefulWidget {
  @override
  _MapLocationPickerPageState createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 선택')),
      body: _selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedPosition!,
                zoom: 15,
              ),
              markers: {
                Marker(markerId: const MarkerId('picked'), position: _selectedPosition!)
              },
              onTap: _onMapTap,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _selectedPosition),
        label: const Text('위치 선택 완료'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}