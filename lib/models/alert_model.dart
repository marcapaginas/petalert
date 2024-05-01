class AlertModel {
  final int id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  bool isNotified;

  AlertModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.isNotified = false,
  });

  AlertModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    DateTime? date,
    bool? isNotified,
  }) {
    return AlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isNotified: isNotified ?? this.isNotified,
    );
  }

  @override
  String toString() {
    return 'AlertModel(id: $id, userId: $userId, title: $title, description: $description, date: $date, isNotified: $isNotified)';
  }
}
