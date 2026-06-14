import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest.dart';
import '../core/api_service.dart';
import '../core/notification_service.dart';
import 'user_provider.dart';

class QuestNotifier extends AsyncNotifier<List<Quest>> {
  @override
  FutureOr<List<Quest>> build() async => _fetchQuests();

  Future<List<Quest>> _fetchQuests() async {
    final response = await apiService.client.get('/quests/');
    return (response.data as List)
        .map((q) => Quest.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  Future<Quest> createQuest(Map<String, dynamic> questData) async {
    final response = await apiService.client.post('/quests/', data: questData);
    final newQuest = Quest.fromJson(response.data as Map<String, dynamic>);
    if (state.hasValue) {
      state = AsyncData([...state.value!, newQuest]);
    } else {
      ref.invalidateSelf();
    }
    return newQuest;
  }

  Future<Quest> updateQuest(int questId, Map<String, dynamic> questData) async {
    final response = await apiService.client.patch('/quests/$questId', data: questData);
    final updated = Quest.fromJson(response.data as Map<String, dynamic>);
    if (state.hasValue) {
      state = AsyncData(
        state.value!.map((q) => q.id == questId ? updated : q).toList(),
      );
    }
    return updated;
  }

  Future<void> completeQuest(int questId) async {
    await apiService.client.patch('/quests/$questId/complete');
    if (state.hasValue) {
      final quests = state.value!
          .map((q) => q.id == questId
              ? q.copyWith(isCompleted: true, completedAt: DateTime.now())
              : q)
          .toList();
      state = AsyncData(quests);
      // Cancel any pending reminder for this quest.
      await NotificationService.instance.cancelForQuest(questId);
      ref.read(userProvider.notifier).refreshUser();
    }
  }

  Future<void> deleteQuest(int questId) async {
    await apiService.client.delete('/quests/$questId');
    if (state.hasValue) {
      state = AsyncData(state.value!.where((q) => q.id != questId).toList());
    }
    await NotificationService.instance.cancelForQuest(questId);
  }
}

final questProvider = AsyncNotifierProvider<QuestNotifier, List<Quest>>(
  () => QuestNotifier(),
);
