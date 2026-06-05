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
    required this.createdAt,
    this.completedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'],
      xpReward: json['xp_reward'],
      coinReward: json['coin_reward'],
      isCompleted: json['is_completed'],
      isRecurring: json['is_recurring'],
      recurringSchedule: json['recurring_schedule'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
