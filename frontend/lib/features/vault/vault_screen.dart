import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/sidebar_drawer.dart';
import '../../providers/user_provider.dart';
import '../../providers/quest_provider.dart';
import '../../models/quest.dart';
import 'dart:io';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final questsAsync = ref.watch(questProvider);

    return Scaffold(
      backgroundColor: IkoTheme.surface,
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: userAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (user) {
                return questsAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (quests) {
                    final completedQuests = quests.where((q) => q.isCompleted).toList();
                    // Calculate attributes based on completed quests
                    int clarity = completedQuests.where((q) => q.category == 'Focus').length * 5;
                    int discipline = completedQuests.where((q) => q.category == 'Wealth' || q.category == 'General').length * 5;
                    int endurance = completedQuests.where((q) => q.category == 'Health').length * 5;
                    int agility = completedQuests.where((q) => q.category == 'Growth').length * 5;
                    
                    // Cap attributes at 100
                    clarity = clarity > 100 ? 100 : clarity;
                    discipline = discipline > 100 ? 100 : discipline;
                    endurance = endurance > 100 ? 100 : endurance;
                    agility = agility > 100 ? 100 : agility;

                    // Recent quests
                    final recentQuests = List<Quest>.from(completedQuests)
                      ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));
                    final top3Recent = recentQuests.take(3).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildTopAppBar(context),
                        const SizedBox(height: 32),
                        _buildProfileSection(user),
                        const SizedBox(height: 32),
                        _buildAttributesSection(clarity, discipline, endurance, agility),
                        const SizedBox(height: 24),
                        _buildRecentSection(top3Recent),
                        const SizedBox(height: 24),
                        _buildHallOfRecordsSection(user.longestStreak, clarity),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardScreen.buildSharedBottomNav(context, 2),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: IkoTheme.surfaceContainer,
            ),
            child: const Icon(Icons.person, size: 20, color: IkoTheme.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'IKO',
          style: TextStyle(
            fontFamily: IkoTheme.serifFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: IkoTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: IkoTheme.primary, width: 2),
                color: IkoTheme.surfaceContainerLowest,
              ),
              child: ClipOval(
                child: user.avatarUrl != null && user.avatarUrl.isNotEmpty
                    ? (kIsWeb 
                        ? Image.network(user.avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80, color: IkoTheme.textSecondary))
                        : Image.file(File(user.avatarUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80, color: IkoTheme.textSecondary)))
                    : const Icon(Icons.person, size: 80, color: IkoTheme.textSecondary),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: IkoTheme.primary,
              ),
              alignment: Alignment.center,
              child: Text(
                '${user.level}',
                style: TextStyle(
                  fontFamily: IkoTheme.sansFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.rpgClass.toUpperCase(),
          style: TextStyle(
            fontFamily: IkoTheme.monoFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: IkoTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.username,
          style: TextStyle(
            fontFamily: IkoTheme.serifFamily,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: IkoTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'A disciplined strategist focused on deep work and systematic growth. Navigating the journey with focus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: IkoTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(Icons.emoji_events_outlined, 'LVL ${user.level}'),
            const SizedBox(width: 16),
            _buildBadge(Icons.star_border, '${user.xp} XP'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: IkoTheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
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

  Widget _buildAttributesSection(int clarity, int discipline, int endurance, int agility) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attributes',
                style: TextStyle(
                  fontFamily: IkoTheme.serifFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: IkoTheme.primary,
                ),
              ),
              Icon(Icons.insights_outlined, color: IkoTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: IkoTheme.hairline),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAttributeBar('CLARITY', clarity)),
              const SizedBox(width: 24),
              Expanded(child: _buildAttributeBar('DISCIPLINE', discipline)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildAttributeBar('ENDURANCE', endurance)),
              const SizedBox(width: 24),
              Expanded(child: _buildAttributeBar('AGILITY', agility)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeBar(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: IkoTheme.monoFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: IkoTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontFamily: IkoTheme.serifFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: IkoTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 4,
            backgroundColor: IkoTheme.surfaceContainer,
            valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(List<Quest> recentQuests) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: TextStyle(
                  fontFamily: IkoTheme.serifFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: IkoTheme.primary,
                ),
              ),
              Icon(Icons.sports_esports_outlined, color: IkoTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: IkoTheme.hairline),
          const SizedBox(height: 16),
          if (recentQuests.isEmpty)
            const Text('No recent activity.', style: TextStyle(color: IkoTheme.textSecondary))
          else
            ...recentQuests.map((q) => _buildRecentItem(q.title, '+${q.xpReward} XP', true)),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String title, String value, bool isPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPrimary ? IkoTheme.primary : const IkoTheme.hairline,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: IkoTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: IkoTheme.monoFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPrimary ? IkoTheme.primary : IkoTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHallOfRecordsSection(int longestStreak, int clarityScore) {
    return InkWell(
      onTap: () => GoRouter.of(context).go('/achievements'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hall of Records',
                style: TextStyle(
                  fontFamily: IkoTheme.serifFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: IkoTheme.primary,
                ),
              ),
              Row(children: [
                Text('View all', style: TextStyle(fontFamily: IkoTheme.monoFamily, fontSize: 11, letterSpacing: 1.6, color: IkoTheme.textSecondary)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 14, color: IkoTheme.textSecondary),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: IkoTheme.hairline),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBadgeItem('Iron Will', '5-day streak', longestStreak < 5)),
              Expanded(child: _buildBadgeItem('Clarity Peak', '10 Focus quests', clarityScore < 50)), // clarity +5 per quest, so 50 = 10 quests
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBadgeItem('Master Strategist', 'Locked', true)),
              Expanded(child: _buildBadgeItem('Zen State', 'Locked', true)),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBadgeItem(String title, String subtitle, bool isLocked) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: IkoTheme.surfaceContainer,
            border: Border.all(
              color: isLocked ? Colors.transparent : const IkoTheme.hairline,
            ),
          ),
          child: isLocked
              ? const Icon(Icons.lock_outline, color: IkoTheme.textTertiary)
              : const Center(child: Text('•', style: TextStyle(fontSize: 24, color: IkoTheme.textSecondary))),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isLocked ? const IkoTheme.textTertiary : IkoTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: isLocked ? const IkoTheme.textTertiary : IkoTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
