import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final int estimatedMinutes;
  final int actualMinutes;
  final int xpReward;
  final String? parentTaskId;
  final List<String> tags;
  final bool isRecurring;
  final String? recurrencePattern;
  final String skillTree;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int streak;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.reminderTime,
    this.estimatedMinutes = 30,
    this.actualMinutes = 0,
    this.xpReward = 15,
    this.parentTaskId,
    this.tags = const [],
    this.isRecurring = false,
    this.recurrencePattern,
    required this.skillTree,
    required this.createdAt,
    this.completedAt,
    this.streak = 0,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? reminderTime,
    int? estimatedMinutes,
    int? actualMinutes,
    int? xpReward,
    String? parentTaskId,
    List<String>? tags,
    bool? isRecurring,
    String? recurrencePattern,
    String? skillTree,
    DateTime? createdAt,
    DateTime? completedAt,
    int? streak,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      xpReward: xpReward ?? this.xpReward,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      skillTree: skillTree ?? this.skillTree,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'status': status.index,
      'dueDate': dueDate?.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'actualMinutes': actualMinutes,
      'xpReward': xpReward,
      'parentTaskId': parentTaskId,
      'tags': tags.join(','),
      'isRecurring': isRecurring ? 1 : 0,
      'recurrencePattern': recurrencePattern,
      'skillTree': skillTree,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'streak': streak,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: TaskPriority.values[map['priority'] as int],
      status: TaskStatus.values[map['status'] as int],
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'] as String)
          : null,
      estimatedMinutes: map['estimatedMinutes'] as int,
      actualMinutes: map['actualMinutes'] as int,
      xpReward: map['xpReward'] as int,
      parentTaskId: map['parentTaskId'] as String?,
      tags: (map['tags'] as String).split(',').where((e) => e.isNotEmpty).toList(),
      isRecurring: map['isRecurring'] == 1,
      recurrencePattern: map['recurrencePattern'] as String?,
      skillTree: map['skillTree'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      streak: map['streak'] as int,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        status,
        dueDate,
        reminderTime,
        estimatedMinutes,
        actualMinutes,
        xpReward,
        parentTaskId,
        tags,
        isRecurring,
        recurrencePattern,
        skillTree,
        createdAt,
        completedAt,
        streak,
      ];
}
