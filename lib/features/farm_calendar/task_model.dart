class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final String? cropType; // New: associated crop

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.cropType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'cropType': cropType,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      cropType: map['cropType'],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    String? cropType,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      cropType: cropType ?? this.cropType,
    );
  }
}
