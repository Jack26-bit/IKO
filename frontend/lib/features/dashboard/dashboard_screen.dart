import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import 'log_activity_modal.dart';
import '../../providers/user_provider.dart';
import '../../providers/quest_provider.dart';
import 'sidebar_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: IkoTheme.surface,
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTopAppBar(context),
                const SizedBox(height: 32),
                _buildHeroSection(context, ref),
                const SizedBox(height: 32),
                _buildActiveQuests(context, ref),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildSharedBottomNav(context, 0),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: IkoTheme.surfaceContainerLowest,
            ),
            child: const Icon(Icons.person, color: IkoTheme.primary),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: IkoTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Color(0xFFFF5252), size: 16),
                  SizedBox(width: 4),
                  Text('12', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: IkoTheme.surfaceContainerLowest,
              ),
              child: const Icon(Icons.notifications_none, color: IkoTheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading user data: $e')),
      data: (user) {
        return Column(
          children: [
            // Master Path Card (Level Ring)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: IkoTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: user.xpProgress,
                          strokeWidth: 8,
                          backgroundColor: IkoTheme.surfaceContainer,
                          color: IkoTheme.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LEVEL',
                            style: TextStyle(
                              fontFamily: IkoTheme.monoFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: IkoTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${user.level}',
                            style: TextStyle(
                              fontFamily: IkoTheme.serifFamily,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: IkoTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mastery Path',
                    style: TextStyle(
                      fontFamily: IkoTheme.serifFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: IkoTheme.primary,
                    ),
                  ),
                  Text(
                    '${user.xp} / ${user.xpNeededForNextLevel} XP to next level',
                    style: const TextStyle(
                      fontSize: 14,
                      color: IkoTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        // XP Bar Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: IkoTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S XP",
                    style: TextStyle(
                      fontFamily: IkoTheme.monoFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: IkoTheme.textSecondary,
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '350',
                          style: TextStyle(
                            fontFamily: IkoTheme.serifFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: IkoTheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' xp',
                          style: TextStyle(
                            fontFamily: IkoTheme.sansFamily,
                            fontSize: 14,
                            color: IkoTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 8,
                  backgroundColor: IkoTheme.surfaceContainer,
                  valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Goal: 500xp',
                  style: TextStyle(
                    fontSize: 14,
                    color: IkoTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: IkoTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_outlined, size: 32, color: IkoTheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      '12',
                      style: TextStyle(
                        fontFamily: IkoTheme.serifFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: IkoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DAY STREAK',
                      style: TextStyle(
                        fontFamily: IkoTheme.monoFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: IkoTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => LogActivityModal.show(context),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: IkoTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Icon(Icons.add, size: 32, color: Colors.white),
                      const Spacer(),
                      Text(
                        'LOG ACTIVITY',
                        style: TextStyle(
                          fontFamily: IkoTheme.monoFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
      },
    );
  }

  Widget _buildActiveQuests(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(questProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Quests',
              style: TextStyle(
                fontFamily: IkoTheme.serifFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: IkoTheme.primary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/quests'),
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  fontFamily: IkoTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        questsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error: $e'),
          data: (quests) {
            final activeQuests = quests.where((q) => !q.isCompleted).take(3).toList();
            if (activeQuests.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No active quests. Go add some!'),
              );
            }
            return Column(
              children: activeQuests.map((quest) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildQuestCard(quest.title, quest.isCompleted ? 1.0 : 0.0, quest.xpReward, Icons.star_border),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestCard(String title, double progress, int xp, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const IkoTheme.hairline), // surface-variant
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: IkoTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: IkoTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: IkoTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: IkoTheme.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: IkoTheme.monoFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: IkoTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '+$xp XP',
            style: TextStyle(
              fontFamily: IkoTheme.monoFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: IkoTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSharedBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const IkoTheme.hairline.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view_rounded, 'Focus', currentIndex == 0, () => context.go('/dashboard')),
            _buildNavItem(Icons.sports_esports_outlined, 'Quests', currentIndex == 1, () => context.go('/quests')),
            _buildNavItem(Icons.emoji_events_outlined, 'Vault', currentIndex == 2, () => context.go('/vault')),
            _buildNavItem(Icons.insights_outlined, 'Growth', currentIndex == 3, () => context.go('/growth')),
          ],
        ),
      ),
    );
  }

  static Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? IkoTheme.surfaceContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? IkoTheme.primary : IkoTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: IkoTheme.monoFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? IkoTheme.primary : IkoTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
