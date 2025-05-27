enum Category { all, study, walking, meal, game, sports, workout }

class Meeting {
  const Meeting({
    required this.category,
    required this.id,
    required this.isRecruiting,
    required this.title,
    required this.time,
    required this.peopleCount,
    required this.imagePath,
  });

  final Category category;
  final int id;
  final bool isRecruiting;
  final String title;
  final String time;
  final int peopleCount;
  final String imagePath;

  // @override
  // String toString() => "$name (id=$id)";
}
