import 'package:flutter/material.dart';

import '../models/quest.dart';
import '../models/user.dart';

/// A single achievement definition. Pure data — no global state.
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int target;
  final int progress;
  final String category;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.target,
    required this.progress,
    required this.category,
  });

  bool get unlocked => progress >= target;
  double get ratio => target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);
}

/// Pure function: derives the full achievement set from current data.
/// Easy to grow — just add another entry to the list.
class AchievementsEngine {
  static List<Achievement> compute(User user, List<Quest> quests) {
    final completed = quests.where((q) => q.isCompleted).toList();
    final completedCount = completed.length;

    final focus = completed.where((q) => q.category == 'Focus').length;
    final health = completed.where((q) => q.category == 'Health').length;
    final growth = completed.where((q) => q.category == 'Growth').length;
    final wealth = completed.where((q) => q.category == 'Wealth').length;

    final hardCount = completed.where((q) => q.difficulty.toLowerCase() == 'hard' || q.difficulty.toLowerCase() == 'epic').length;

    int beforeNoon = 0;
    int afterTen = 0;
    for (final q in completed) {
      final t = q.completedAt;
      if (t == null) continue;
      if (t.hour < 12) beforeNoon++;
      if (t.hour >= 22) afterTen++;
    }

    return [
      Achievement(
        id: 'first_step',
        name: 'First Step',
        description: 'Complete your first quest.',
        icon: Icons.flag_outlined,
        target: 1,
        progress: completedCount,
        category: 'Origin',
      ),
      Achievement(
        id: 'iron_will',
        name: 'Iron Will',
        description: 'Hold a 5-day streak.',
        icon: Icons.bolt_outlined,
        target: 5,
        progress: user.longestStreak,
        category: 'Discipline',
      ),
      Achievement(
        id: 'cathedral',
        name: 'Cathedral',
        description: 'Reach a 30-day streak.',
        icon: Icons.account_balance_outlined,
        target: 30,
        progress: user.longestStreak,
        category: 'Discipline',
      ),
      Achievement(
        id: 'centurion',
        name: 'Centurion',
        description: 'Complete 100 quests.',
        icon: Icons.workspace_premium_outlined,
        target: 100,
        progress: completedCount,
        category: 'Volume',
      ),
      Achievement(
        id: 'scholar',
        name: 'Scholar',
        description: 'Complete 20 Growth quests.',
        icon: Icons.menu_book_outlined,
        target: 20,
        progress: growth,
        category: 'Growth',
      ),
      Achievement(
        id: 'monk',
        name: 'Monk',
        description: 'Complete 20 Focus quests.',
        icon: Icons.self_improvement_outlined,
        target: 20,
        progress: focus,
        category: 'Focus',
      ),
      Achievement(
        id: 'titan',
        name: 'Titan',
        description: 'Complete 20 Health quests.',
        icon: Icons.fitness_center_outlined,
        target: 20,
        progress: health,
        category: 'Health',
      ),
      Achievement(
        id: 'merchant',
        name: 'Merchant',
        description: 'Complete 10 Wealth quests.',
        icon: Icons.savings_outlined,
        target: 10,
        progress: wealth,
        category: 'Wealth',
      ),
      Achievement(
        id: 'high_stakes',
        name: 'High Stakes',
        description: 'Complete 10 Hard or Epic quests.',
        icon: Icons.local_fire_department_outlined,
        target: 10,
        progress: hardCount,
        category: 'Difficulty',
      ),
      Achievement(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Complete 10 quests before noon.',
        icon: Icons.wb_twilight_outlined,
        target: 10,
        progress: beforeNoon,
        category: 'Rhythm',
      ),
      Achievement(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Complete 10 quests after 10pm.',
        icon: Icons.dark_mode_outlined,
        target: 10,
        progress: afterTen,
        category: 'Rhythm',
      ),
      Achievement(
        id: 'ascendant',
        name: 'Ascendant',
        description: 'Reach Level 10.',
        icon: Icons.auto_awesome_outlined,
        target: 10,
        progress: user.level,
        category: 'Path',
      ),
    ];
  }
}
