enum TaskStatus { todo, inProgress, review, done }
enum TaskPriority { low, medium, high }

class KanbanTask {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final TaskStatus status;
  final TaskPriority priority;

  KanbanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.status,
    required this.priority,
  });

  KanbanTask copyWith({
    String? id,
    String? title,
    String? description,
    String? assignee,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return KanbanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}
