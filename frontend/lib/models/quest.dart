class Quest {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String difficulty;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;
  final bool isRecurring;
  final String? recurringSchedule;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  Quest({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    required this.isCompleted,
    required this.isRecurring,
    this.recurringSchedule,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: (json['category'] as String?) ?? 'General',
      difficulty: (json['difficulty'] as String?) ?? 'medium',
      xpReward: json['xp_reward'] as int? ?? 50,
      coinReward: json['coin_reward'] as int? ?? 10,
      isCompleted: json['is_completed'] as bool? ?? false,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringSchedule: json['recurring_schedule'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
    );
  }

  Quest copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    int? xpReward,
    int? coinReward,
    bool? isCompleted,
    bool? isRecurring,
    String? recurringSchedule,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
  }) =>
      Quest(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        xpReward: xpReward ?? this.xpReward,
        coinReward: coinReward ?? this.coinReward,
        isCompleted: isCompleted ?? this.isCompleted,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringSchedule: recurringSchedule ?? this.recurringSchedule,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
