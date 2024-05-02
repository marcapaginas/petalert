class AlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool isDiscarded;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isDiscarded = false,
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isDiscarded,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDiscarded: isDiscarded ?? this.isDiscarded,
    );
  }

  @override
  String toString() {
    return 'AlertModel(id: $id, title: $title, description: $description, date: $date, isDiscarded: $isDiscarded)';
  }
}
