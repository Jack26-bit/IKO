import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest.dart';
import '../core/api_service.dart';
import 'user_provider.dart';

class QuestNotifier extends AsyncNotifier<List<Quest>> {
  @override
  FutureOr<List<Quest>> build() async {
    return _fetchQuests();
  }

  Future<List<Quest>> _fetchQuests() async {
    final response = await apiService.client.get('/quests/');
    return (response.data as List).map((q) => Quest.fromJson(q)).toList();
  }

  Future<void> createQuest(Map<String, dynamic> questData) async {
    try {
      final response = await apiService.client.post('/quests/', data: questData);
      final newQuest = Quest.fromJson(response.data);
      
      if (state.hasValue) {
        state = AsyncData([...state.value!, newQuest]);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeQuest(int questId) async {
    try {
      await apiService.client.patch('/quests/$questId/complete');
      
      if (state.hasValue) {
        final quests = state.value!.map((q) {
          if (q.id == questId) {
            return Quest(
              id: q.id,
              title: q.title,
              description: q.description,
              category: q.category,
              difficulty: q.difficulty,
              xpReward: q.xpReward,
              coinReward: q.coinReward,
              isCompleted: true,
              isRecurring: q.isRecurring,
              recurringSchedule: q.recurringSchedule,
              createdAt: q.createdAt,
              completedAt: DateTime.now(),
            );
          }
          return q;
        }).toList();
        state = AsyncData(quests);
        
        ref.read(userProvider.notifier).refreshUser();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logActivity({
    required String title,
    String? description,
    required String category,
    required int xpReward,
  }) async {
    try {
      final response = await apiService.client.post('/quests/', data: {
        'title': title,
        'description': description,
        'category': category,
        'difficulty': 'medium',
        'xp_reward': xpReward,
      });
      final newQuest = Quest.fromJson(response.data);

      if (state.hasValue) {
        state = AsyncData([...state.value!, newQuest]);
      }
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  Future<void> deleteQuest(int questId) async {
    try {
      await apiService.client.delete('/quests/$questId');
      
      if (state.hasValue) {
        final quests = state.value!.where((q) => q.id != questId).toList();
        state = AsyncData(quests);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final questProvider = AsyncNotifierProvider<QuestNotifier, List<Quest>>(() {
  return QuestNotifier();
});
