import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../../providers/quest_provider.dart';
import '../../models/quest.dart';
import '../dashboard/sidebar_drawer.dart';
import '../../widgets/menu_drawer_button.dart';
import '../dashboard/log_activity_modal.dart';
import '../../core/week_utils.dart';


class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questProvider);

    return Scaffold(
      backgroundColor: IkoTheme.surface,
      drawer: const SidebarDrawer(),
      body: Builder(
        builder: (scaffoldContext) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopAppBar(scaffoldContext),
                const SizedBox(height: 24),
                const Text(
                  'Active Quests',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: IkoTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete your daily objectives to maintain momentum. Progression is tracked linearly for sustained focus.',
                  style: TextStyle(
                    fontSize: 14,
                    color: IkoTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                questsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading quests: $err'),
                  data: (quests) {
                    final completedThisWeek = quests.where(isCompletedThisWeek).length;
                    final totalQuests = quests.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeeklyVelocityCard(completedThisWeek, totalQuests),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daily Objectives',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: IkoTheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: IkoTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${quests.where((q) => q.isCompleted).length}/${quests.length} Completed',
                                style: const TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: IkoTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Swipe left to delete a quest',
                          style: TextStyle(
                            fontSize: 11,
                            color: IkoTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...quests.map((quest) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Dismissible(
                              key: ValueKey('quest_${quest.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4444),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.white, size: 24),
                                    SizedBox(height: 4),
                                    Text(
                                      'DELETE',
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (_) {
                                ref.read(questProvider.notifier).deleteQuest(quest.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${quest.title} removed'),
                                    backgroundColor: IkoTheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: _buildObjectiveCard(quest),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                const Text(
                  'Weekly Milestones',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: IkoTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                questsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading quests: $err'),
                  data: (quests) {
                    final healthQuestsThisWeek = countCompletedThisWeek(quests, 'Health');
                    final growthQuestsThisWeek = countCompletedThisWeek(quests, 'Growth');
                    final focusQuestsThisWeek = countCompletedThisWeek(quests, 'Focus');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMilestoneCard('Physical Activity', healthQuestsThisWeek, 4, Icons.fitness_center),
                        const SizedBox(height: 12),
                        _buildMilestoneCard('Reading Sessions', growthQuestsThisWeek, 2, Icons.menu_book),
                        const SizedBox(height: 12),
                        _buildMilestoneCard('Weekly Review', focusQuestsThisWeek, 1, Icons.lock_outline, isLocked: focusQuestsThisWeek == 0),
                      ],
                    );
                  },
                ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardScreen.buildSharedBottomNav(context, 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LogActivityModal.show(context, mode: ActivityModalMode.createQuest),
        backgroundColor: IkoTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW QUEST', style: TextStyle(color: Colors.white, fontFamily: 'Geist', fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      children: [
        const MenuDrawerButton(size: 32),
        const SizedBox(width: 8),
        const Text(
          'IKO',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: IkoTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyVelocityCard(int completedThisWeek, int totalQuests) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Velocity',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: IkoTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(completedThisWeek / (totalQuests == 0 ? 1 : totalQuests) * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: IkoTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'completion',
                style: TextStyle(
                  fontSize: 14,
                  color: IkoTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalQuests == 0 ? 0 : completedThisWeek / totalQuests,
              minHeight: 2,
              backgroundColor: const Color(0xFFE2E2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mon', style: TextStyle(fontSize: 12, color: IkoTheme.textSecondary, fontWeight: FontWeight.w500)),
              Text('Sun', style: TextStyle(fontSize: 12, color: IkoTheme.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard(Quest quest) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent,
          width: 0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: quest.isCompleted
                ? null
                : () => ref.read(questProvider.notifier).completeQuest(quest.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: quest.isCompleted ? IkoTheme.primary : Colors.transparent,
                border: Border.all(
                  color: quest.isCompleted ? IkoTheme.primary : const Color(0xFFE2E2E2),
                  width: 2,
                ),
              ),
              child: quest.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: quest.isCompleted ? IkoTheme.textSecondary : IkoTheme.primary,
                            decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: quest.isCompleted ? IkoTheme.primary : IkoTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${quest.xpReward}xp',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: quest.isCompleted ? Colors.white : IkoTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (quest.description != null && quest.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      quest.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: IkoTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String title, int current, int total, IconData icon, {bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isLocked ? const Color(0xFFBDBDBD) : IkoTheme.textSecondary, size: 24),
              Text(
                '$current/$total',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? const Color(0xFFBDBDBD) : IkoTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLocked ? const Color(0xFFBDBDBD) : IkoTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? current / total : 0,
              minHeight: 2,
              backgroundColor: isLocked ? Colors.transparent : IkoTheme.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
            ),
          ),
        ],
      ),
    );
  }


}
