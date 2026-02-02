class SubTaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  SubTaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory SubTaskModel.fromMap(Map<String, dynamic> map, String id) {
    return SubTaskModel(
      id: id,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  SubTaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
