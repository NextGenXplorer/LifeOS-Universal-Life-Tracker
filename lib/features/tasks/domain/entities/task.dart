enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? categoryId;
  final List<String> tags;
  final bool isRecurring;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => completedAt != null;
  bool get isOverdue => dueDate != null && 
      !isCompleted && 
      dueDate!.isBefore(DateTime.now());

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.completedAt,
    this.categoryId,
    this.tags = const [],
    this.isRecurring = false,
    this.recurrenceRule,
    required this.createdAt,
    required this.updatedAt,
  });
}
