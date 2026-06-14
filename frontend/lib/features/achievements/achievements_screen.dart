import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements.dart';
import '../../core/theme.dart';
import '../../providers/quest_provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/sidebar_drawer.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final questsAsync = ref.watch(questProvider);

    return Scaffold(
      backgroundColor: IkoTheme.background,
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (user) => questsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (quests) {
              final all = AchievementsEngine.compute(user, quests);
              final unlocked = all.where((a) => a.unlocked).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(context),
                    const SizedBox(height: 28),
                    Text('ACHIEVEMENTS', style: IkoTheme.mono(letterSpacing: 2.4)),
                    const SizedBox(height: 6),
                    Text('Hall of Records', style: IkoTheme.display(size: 36)),
                    const SizedBox(height: 8),
                    Text(
                      'Earned through quiet repetition. ${unlocked.length} of ${all.length} unlocked.',
                      style: IkoTheme.body(size: 14, color: IkoTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    _summary(unlocked.length, all.length),
                    const SizedBox(height: 28),
                    Text('UNLOCKED · ${unlocked.length}', style: IkoTheme.mono(letterSpacing: 2)),
                    const SizedBox(height: 12),
                    if (unlocked.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: IkoTheme.surfaceContainerLowest,
                          border: Border.all(color: IkoTheme.hairline),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('Nothing yet — but the page is open.',
                            style: IkoTheme.body(size: 14, color: IkoTheme.textSecondary)),
                      )
                    else
                      _grid(unlocked, locked: false),
                    const SizedBox(height: 28),
                    Text('IN PROGRESS · ${all.length - unlocked.length}', style: IkoTheme.mono(letterSpacing: 2)),
                    const SizedBox(height: 12),
                    _grid(all.where((a) => !a.unlocked).toList(), locked: true),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: DashboardScreen.buildSharedBottomNav(context, -1),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: IkoTheme.hairline),
                ),
                child: const Icon(Icons.person_outline, size: 18, color: IkoTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('IKO', style: IkoTheme.display(size: 22, letterSpacing: 4)),
        ],
      ),
    );
  }

  Widget _summary(int unlocked, int total) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        border: Border.all(color: IkoTheme.hairline),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COMPLETION', style: IkoTheme.mono(letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('${(pct * 100).round()}%', style: IkoTheme.display(size: 48)),
                const SizedBox(height: 6),
                Text('$unlocked of $total earned',
                    style: IkoTheme.body(size: 12, color: IkoTheme.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            width: 84, height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84, height: 84,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v, strokeWidth: 6,
                      backgroundColor: IkoTheme.surfaceContainer,
                      color: IkoTheme.primary,
                    ),
                  ),
                ),
                const Icon(Icons.emoji_events_outlined, size: 24, color: IkoTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<Achievement> items, {required bool locked}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (_, i) => _card(items[i], locked: locked)
          .animate(delay: Duration(milliseconds: 40 * i))
          .fadeIn(duration: 360.ms)
          .slideY(begin: 0.06, end: 0, duration: 360.ms),
    );
  }

  Widget _card(Achievement a, {required bool locked}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: locked ? IkoTheme.surfaceContainerLowest : IkoTheme.primary,
        border: Border.all(color: locked ? IkoTheme.hairline : IkoTheme.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked ? IkoTheme.surfaceContainer : Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: locked ? IkoTheme.hairline : Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(
              locked ? Icons.lock_outline : a.icon,
              size: 18,
              color: locked ? IkoTheme.textSecondary : Colors.white,
            ),
          ),
          const Spacer(),
          Text(a.category.toUpperCase(),
              style: IkoTheme.mono(
                color: locked ? IkoTheme.textTertiary : Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1.8,
              )),
          const SizedBox(height: 4),
          Text(
            a.name,
            style: IkoTheme.serif(
              size: 18,
              weight: FontWeight.w600,
              color: locked ? IkoTheme.primary : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: IkoTheme.body(
              size: 12,
              color: locked ? IkoTheme.textSecondary : Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: a.ratio,
              minHeight: 3,
              backgroundColor: locked ? IkoTheme.surfaceContainer : Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(locked ? IkoTheme.primary : Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${a.progress.clamp(0, a.target)} / ${a.target}',
            style: IkoTheme.mono(
              color: locked ? IkoTheme.textSecondary : Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
