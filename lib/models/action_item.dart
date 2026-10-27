/// A task assigned to fix a gap, stored at schools/{schoolId}/actions/{id}.
/// Named ActionItem because Flutter already has a class called Action.
class ActionItem {
  const ActionItem({
    required this.id,
    required this.gapId,
    required this.title,
    required this.ownerName,
    required this.dueDate,
    this.status = statusTodo,
    this.notes = '',
    this.createdAt,
  });

  static const statusTodo = 'todo';
  static const statusInProgress = 'in_progress';
  static const statusDone = 'done';
  static const statuses = [statusTodo, statusInProgress, statusDone];

  final String id;
  final String gapId;
  final String title;
  final String ownerName;

  /// A calendar day, stored at local midnight.
  final DateTime dueDate;

  /// One of the status constants above.
  final String status;
  final String notes;

  /// Set by the server, so it is null until the action has been read back.
  final DateTime? createdAt;

  bool get isDone => status == statusDone;

  /// Overdue means the due day has fully passed and the action is not done.
  bool isOverdueOn(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return !isDone && dueDate.isBefore(today);
  }

  ActionItem copyWith({String? id, String? status}) {
    return ActionItem(
      id: id ?? this.id,
      gapId: gapId,
      title: title,
      ownerName: ownerName,
      dueDate: dueDate,
      status: status ?? this.status,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Expects dates already converted from Firestore Timestamps to DateTime.
  factory ActionItem.fromMap(String id, Map<String, dynamic> map) {
    return ActionItem(
      id: id,
      gapId: map['gapId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      dueDate: map['dueDate'] as DateTime? ?? DateTime.now(),
      status: map['status'] as String? ?? statusTodo,
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] as DateTime?,
    );
  }

  /// Leaves out createdAt, which the service sets to the server time.
  Map<String, dynamic> toMap() {
    return {
      'gapId': gapId,
      'title': title,
      'ownerName': ownerName,
      'dueDate': dueDate,
      'status': status,
      'notes': notes,
    };
  }
}
