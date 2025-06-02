import 'package:likelion/model/meeting.dart';

class MeetingsRepository {
  static List<Meeting> loadMeetings() {
    const allMeetings = <Meeting>[
      Meeting(
        id: 0,
        category: Category.study,
        isRecruiting: true,
        title: 'Flutter Study Group',
        time: '2025-05-30 19:00',
        peopleCount: 5,
        imagePath: "assets/DOST-logo.png",
      ),
      Meeting(
        id: 1,
        category: Category.game,
        isRecruiting: true,
        title: 'Weekend Game Night',
        time: '2025-05-31 20:00',
        peopleCount: 4,
        imagePath: "assets/DOST-logo.png",
      ),
      Meeting(
        id: 2,
        category: Category.meal,
        isRecruiting: false,
        title: 'Lunch at Korean BBQ',
        time: '2025-06-01 12:00',
        peopleCount: 6,
        imagePath: "assets/DOST-logo.png",
      ),
      Meeting(
        id: 3,
        category: Category.sports,
        isRecruiting: true,
        title: 'Sunday Morning Soccer',
        time: '2025-06-02 08:00',
        peopleCount: 10,
        imagePath: "assets/DOST-logo.png",
      ),
    ];
    return allMeetings.toList();
  }
}
