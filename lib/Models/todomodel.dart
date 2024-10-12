class TaskModel {
  String id;
  String? assignerId;
  String? assigneeId;
  String projectId;
  String? sectionId;
  String? parentId;
  int order;
  String content;
  String description;
  bool isCompleted;
  List<String> labels;
  int priority;
  int commentCount;
  String creatorId;
  DateTime createdAt;
  DateTime? due;
  String url;
  String? duration;
  String? deadline;

  TaskModel({
    required this.id,
    this.assignerId,
    this.assigneeId,
    required this.projectId,
    this.sectionId,
    this.parentId,
    required this.order,
    required this.content,
    this.description = '',
    required this.isCompleted,
    required this.labels,
    required this.priority,
    required this.commentCount,
    required this.creatorId,
    required this.createdAt,
    this.due,
    required this.url,
    this.duration,
    this.deadline,
  });

  // Method to create TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      assignerId: json['assigner_id'],
      assigneeId: json['assignee_id'],
      projectId: json['project_id'],
      sectionId: json['section_id'],
      parentId: json['parent_id'],
      order: json['order'],
      content: json['content'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'],
      labels: List<String>.from(json['labels']),
      priority: json['priority'],
      commentCount: json['comment_count'],
      creatorId: json['creator_id'],
      createdAt: DateTime.parse(json['created_at']),
      due: json['due'] != null ? DateTime.parse(json['due']) : null,
      url: json['url'],
      duration: json['duration'],
      deadline: json['deadline'],
    );
  }

  // Method to convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assigner_id': assignerId,
      'assignee_id': assigneeId,
      'project_id': projectId,
      'section_id': sectionId,
      'parent_id': parentId,
      'order': order,
      'content': content,
      'description': description,
      'is_completed': isCompleted,
      'labels': labels,
      'priority': priority,
      'comment_count': commentCount,
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
      'due': due?.toIso8601String(),
      'url': url,
      'duration': duration,
      'deadline': deadline,
    };
  }
}
