import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doova/model/add_task/category.dart';
import 'package:intl/intl.dart';

class TaskModel {
  final String taskId;
  final String id;
  final String title;
  final String description;
  final int priority;
  final CategoryModel category;
  final String time;
  final String date;
  final String userId;
  final DateTime createdAt;
  bool isCompleted;
  bool isRepeating; 

  TaskModel({
    required this.taskId,
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.time,
    required this.date,
    required this.userId,
    required this.createdAt,
    required this.isCompleted, // ✅
     required this.isRepeating,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id,) {
    return TaskModel(
      taskId: map['taskId'] ?? id,
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 0,
      category: CategoryModel.fromMap(map['category']),
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false, // ✅
        isRepeating: map['isRepeating'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category.toMap(),
      'time': time,
      'date': date,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted, // ✅
      'isRepeating': isRepeating
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? id,
    String? title,
    String? description,
    int? priority,
    CategoryModel? category,
    String? time,
    String? date,
    String? userId,
    DateTime? createdAt,
    bool? isCompleted, // ✅
     bool? isRepeating, // ✅
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      time: time ?? this.time,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted, // ✅
        isRepeating: isRepeating ?? this.isRepeating, // ✅
    );
  }

  String get formattedTime {
    try {
      final now = DateTime.now();

      // Parse your saved date — assuming it’s stored like: 'Wed, Jun 5, 2025'
      final parsedDate = DateFormat('EEE, MMM d, y').parse(date);

      // Parse your saved time — assuming it’s stored like: '11:00 PM' or '11:00 AM'
      final parsedTime = DateFormat.jm().parse(time);

      // Merge both into single DateTime if needed
      final combined = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      final isToday = now.year == combined.year &&
          now.month == combined.month &&
          now.day == combined.day;

      final dayLabel = isToday ? 'Today' : DateFormat('EEEE').format(combined);
      final timeLabel = DateFormat.jm().format(combined); // e.g., 11:00 AM

      return '$dayLabel at $timeLabel';
    } catch (e) {
      return 'Today at $time'; // fallback
    }
  }
}
