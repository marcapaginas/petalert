class AlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool isNotified;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isNotified = false,
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isNotified,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isNotified: isNotified ?? this.isNotified,
    );
  }

  @override
  String toString() {
    return 'AlertModel(id: $id, title: $title, description: $description, date: $date, isNotified: $isNotified)';
  }
}
