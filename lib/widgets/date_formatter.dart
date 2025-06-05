import 'package:intl/intl.dart';

String formatMeetingDate(String date, String startTime, String endTime) {
  try {
    final DateTime baseDate = DateTime.parse(date);

    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateTime startTimeParsed = timeFormat.parse(startTime);
    final DateTime endTimeParsed = timeFormat.parse(endTime);

    final DateTime startDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      startTimeParsed.hour,
      startTimeParsed.minute,
    );

    DateTime endDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      endTimeParsed.hour,
      endTimeParsed.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      // 종료 시간이 시작 시간보다 빠르면 다음날로 간주
      endDateTime = endDateTime.add(Duration(days: 1));
    }

    final weekdayMap = ['월', '화', '수', '목', '금', '토', '일'];

    String startStr =
        '${startDateTime.month}월 ${startDateTime.day}일 (${weekdayMap[startDateTime.weekday - 1]}) ${_twoDigit(startDateTime.hour)}:${_twoDigit(startDateTime.minute)}';

    if (startDateTime.year == endDateTime.year &&
        startDateTime.month == endDateTime.month &&
        startDateTime.day == endDateTime.day) {
      // 같은 날일 경우
      return '$startStr ~ ${_twoDigit(endDateTime.hour)}:${_twoDigit(endDateTime.minute)}';
    } else {
      // 날짜가 다를 경우
      String endStr =
          '${endDateTime.month}월 ${endDateTime.day}일 (${weekdayMap[endDateTime.weekday - 1]}) ${_twoDigit(endDateTime.hour)}:${_twoDigit(endDateTime.minute)}';

      return '$startStr ~ $endStr';
    }
  } catch (e) {
    return '날짜 형식 오류';
  }
}

String _twoDigit(int n) => n.toString().padLeft(2, '0');
