import '../models/quest.dart';

DateTime startOfWeek(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final weekday = local.weekday;
  return local.subtract(Duration(days: weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime date) {
  return startOfWeek(date).add(const Duration(days: 7));
}

bool isCompletedThisWeek(Quest quest) {
  if (!quest.isCompleted || quest.completedAt == null) return false;
  final now = DateTime.now();
  final weekStart = startOfWeek(now);
  final weekEnd = endOfWeek(now);
  final completed = quest.completedAt!.toLocal();
  return !completed.isBefore(weekStart) && completed.isBefore(weekEnd);
}

int countCompletedThisWeek(List<Quest> quests, String category) {
  return quests.where((q) => q.category == category && isCompletedThisWeek(q)).length;
}
